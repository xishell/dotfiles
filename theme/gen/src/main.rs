//! ember-gen: render theme/palette.toml into every config that needs colour.
//!
//! Templates live in theme/templates/, the template → output map in
//! theme/targets.toml. Placeholders are `{{ token }}` or `{{ token | filter[:arg] }}`;
//! tokens are the keys of [colors] and [ansi], plus `meta.<key>` for plain strings.
//!
//!   ember-gen            write every output that changed
//!   ember-gen --check    exit 1 if any output differs from its template (drift or hand edit)
//!   ember-gen --root DIR repo root (default: two levels above this crate)

use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

const BEGIN: &str = "ember:begin";
const END: &str = "ember:end";

#[derive(Clone, Copy)]
struct Rgb(u8, u8, u8);

impl Rgb {
    fn parse(s: &str) -> Result<Rgb, String> {
        let h = s.strip_prefix('#').ok_or_else(|| format!("{s:?}: colours start with #"))?;
        if h.len() != 6 || !h.bytes().all(|b| b.is_ascii_hexdigit()) {
            return Err(format!("{s:?}: expected #rrggbb"));
        }
        let c = |i| u8::from_str_radix(&h[i..i + 2], 16).unwrap();
        Ok(Rgb(c(0), c(2), c(4)))
    }

    fn bare(self) -> String {
        format!("{:02x}{:02x}{:02x}", self.0, self.1, self.2)
    }
}

enum Value {
    Color(Rgb),
    Text(String),
}

struct Palette(BTreeMap<String, Value>);

impl Palette {
    fn load(path: &Path) -> Result<Palette, String> {
        let src = fs::read_to_string(path).map_err(|e| format!("{}: {e}", path.display()))?;
        let doc: toml::Table = src.parse().map_err(|e| format!("{}: {e}", path.display()))?;
        let mut map = BTreeMap::new();
        for (section, table) in &doc {
            let table = table.as_table().ok_or_else(|| format!("[{section}] must be a table"))?;
            for (key, v) in table {
                // Arrays become indexed tokens: wallpaper.sky.0, wallpaper.sky.1, …
                let items: Vec<(String, &toml::Value)> = match v.as_array() {
                    Some(a) => a.iter().enumerate().map(|(i, x)| (format!("{key}.{i}"), x)).collect(),
                    None => vec![(key.clone(), v)],
                };
                for (key, v) in items {
                    let s = v.as_str().ok_or_else(|| format!("{section}.{key} must be a string"))?;
                    let (name, value) = match section.as_str() {
                        "colors" | "ansi" => (key.clone(), Value::Color(Rgb::parse(s).map_err(|e| format!("{section}.{key}: {e}"))?)),
                        // Other sections: hex strings are colours (filters work), the rest text
                        _ => (format!("{section}.{key}"), Rgb::parse(s).map_or_else(|_| Value::Text(s.to_string()), Value::Color)),
                    };
                    if map.insert(name.clone(), value).is_some() {
                        return Err(format!("token {name} is defined twice"));
                    }
                }
            }
        }
        Ok(Palette(map))
    }

    fn render(&self, expr: &str) -> Result<String, String> {
        let (token, filter) = match expr.split_once('|') {
            Some((t, f)) => (t.trim(), Some(f.trim())),
            None => (expr.trim(), None),
        };
        let value = self.0.get(token).ok_or_else(|| format!("unknown token {token:?}"))?;
        let c = match value {
            Value::Text(s) if filter.is_none() => return Ok(s.clone()),
            Value::Text(_) => return Err(format!("{token} is text; filters only apply to colours")),
            Value::Color(c) => *c,
        };
        let (name, arg) = match filter {
            Some(f) => match f.split_once(':') {
                Some((n, a)) => (n.trim(), Some(a.trim())),
                None => (f, None),
            },
            None => ("hex", None),
        };
        let alpha_hex = |a: Option<&str>| -> Result<String, String> {
            let a = a.ok_or_else(|| format!("{name} needs an alpha, e.g. {name}:ee"))?;
            if a.len() == 2 && a.bytes().all(|b| b.is_ascii_hexdigit()) {
                Ok(a.to_ascii_lowercase())
            } else {
                Err(format!("{name}:{a}: alpha is two hex digits"))
            }
        };
        Ok(match (name, arg) {
            ("hex", None) => format!("#{}", c.bare()),
            ("bare", None) => c.bare(),
            ("rgb", None) => format!("{}, {}, {}", c.0, c.1, c.2),
            // CSS rgba(r, g, b, a) with a as 0..1
            ("rgba", Some(a)) => {
                let f: f32 = a.parse().map_err(|_| format!("rgba:{a}: alpha is 0..1"))?;
                format!("rgba({}, {}, {}, {f})", c.0, c.1, c.2)
            }
            ("hexa", a) => format!("#{}{}", c.bare(), alpha_hex(a)?),
            ("hypr", None) => format!("rgb({})", c.bare()),
            ("hypr", a) => format!("rgba({}{})", c.bare(), alpha_hex(a)?),
            // mix:<token>:<amount>: this colour laid over <token> at <amount> (0..1), as #rrggbb.
            // For tints the palette doesn't name, e.g. a diff background {{ green | mix:base:0.2 }}
            ("mix", Some(a)) => {
                let (other, amount) = a.split_once(':').ok_or_else(|| format!("mix:{a}: expected mix:<token>:<0..1>"))?;
                let amount: f32 = amount.trim().parse().map_err(|_| format!("mix:{a}: amount is 0..1"))?;
                let o = match self.0.get(other.trim()) {
                    Some(Value::Color(o)) => *o,
                    _ => return Err(format!("mix: {other:?} is not a colour token")),
                };
                let ch = |x: u8, y: u8| (x as f32 * amount + y as f32 * (1.0 - amount)).round() as u8;
                format!("#{}", Rgb(ch(c.0, o.0), ch(c.1, o.1), ch(c.2, o.2)).bare())
            }
            _ => return Err(format!("unknown filter {:?}", filter.unwrap_or(""))),
        })
    }

    fn fill(&self, template: &str) -> Result<String, String> {
        let mut out = String::with_capacity(template.len());
        let mut rest = template;
        while let Some(start) = rest.find("{{") {
            out.push_str(&rest[..start]);
            let after = &rest[start + 2..];
            let end = after.find("}}").ok_or("unclosed {{")?;
            out.push_str(&self.render(&after[..end])?);
            rest = &after[end + 2..];
        }
        out.push_str(rest);
        Ok(out)
    }
}

struct Target {
    template: String,
    output: String,
    comment: String,
    region: bool,
}

fn load_targets(path: &Path) -> Result<Vec<Target>, String> {
    let src = fs::read_to_string(path).map_err(|e| format!("{}: {e}", path.display()))?;
    let doc: toml::Table = src.parse().map_err(|e| format!("{}: {e}", path.display()))?;
    let list = doc.get("target").and_then(|t| t.as_array()).ok_or("targets.toml needs [[target]] entries")?;
    list.iter()
        .map(|t| {
            let s = |k: &str| t.get(k).and_then(|v| v.as_str()).map(str::to_string);
            Ok(Target {
                template: s("template").ok_or("target without template")?,
                output: s("output").ok_or("target without output")?,
                comment: s("comment").unwrap_or_default(),
                region: t.get("region").and_then(|v| v.as_bool()).unwrap_or(false),
            })
        })
        .collect()
}

/// The full text the output file should contain.
fn expected(root: &Path, palette: &Palette, t: &Target) -> Result<String, String> {
    let tpl_path = root.join("theme/templates").join(&t.template);
    let tpl = fs::read_to_string(&tpl_path).map_err(|e| format!("{}: {e}", tpl_path.display()))?;
    let body = palette.fill(&tpl).map_err(|e| format!("{}: {e}", t.template))?;
    let c = &t.comment;
    // Block comments ("/*") need closing
    let close = if c == "/*" { " */" } else { "" };
    let header = format!("{c} generated by theme/gen from theme/palette.toml (template: theme/templates/{}); edit those, not this{close}", t.template);

    if !t.region {
        return Ok(if c.is_empty() { body } else { format!("{header}\n{body}") });
    }
    // Region mode: keep the hand-written file, swap only the marked block
    let out_path = root.join(&t.output);
    let current = fs::read_to_string(&out_path).map_err(|e| format!("{}: {e}", out_path.display()))?;
    let begin = format!("{c} {BEGIN}");
    let end = format!("{c} {END}");
    let b = current.find(&begin).ok_or_else(|| format!("{}: missing `{begin}` marker", t.output))?;
    let line_end = current[b..].find('\n').map_or(current.len(), |i| b + i + 1);
    let e = current[line_end..].find(&end).ok_or_else(|| format!("{}: missing `{end}` marker", t.output))? + line_end;
    Ok(format!("{}{header}\n{body}{}", &current[..line_end], &current[e..]))
}

fn main() -> ExitCode {
    let mut args = std::env::args().skip(1);
    let mut check = false;
    let mut root = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../..");
    while let Some(a) = args.next() {
        match a.as_str() {
            "--check" => check = true,
            "--root" => root = args.next().map(PathBuf::from).unwrap_or(root),
            "-h" | "--help" => {
                println!("usage: ember-gen [--check] [--root DIR]");
                return ExitCode::SUCCESS;
            }
            _ => {
                eprintln!("ember-gen: unknown argument {a:?}");
                return ExitCode::from(2);
            }
        }
    }
    match run(&root, check) {
        Ok(true) => ExitCode::SUCCESS,
        Ok(false) => ExitCode::FAILURE,
        Err(e) => {
            eprintln!("ember-gen: {e}");
            ExitCode::from(2)
        }
    }
}

fn run(root: &Path, check: bool) -> Result<bool, String> {
    let palette = Palette::load(&root.join("theme/palette.toml"))?;
    let targets = load_targets(&root.join("theme/targets.toml"))?;
    let mut clean = true;
    for t in &targets {
        let want = expected(root, &palette, t)?;
        let path = root.join(&t.output);
        let have = fs::read_to_string(&path).ok();
        if have.as_deref() == Some(want.as_str()) {
            continue;
        }
        if check {
            println!("stale  {}", t.output);
            clean = false;
        } else {
            if let Some(dir) = path.parent() {
                fs::create_dir_all(dir).map_err(|e| format!("{}: {e}", dir.display()))?;
            }
            fs::write(&path, &want).map_err(|e| format!("{}: {e}", path.display()))?;
            println!("wrote  {}", t.output);
        }
    }
    if check && clean {
        println!("all {} outputs match theme/palette.toml", targets.len());
    }
    Ok(clean)
}
