# ==========================
# Global latexmkrc for VimTeX + Biber
# Handles split aux/output dirs and auto-runs Biber.
# ==========================

# --- Defaults (for plain latexmk runs without -auxdir/-outdir) ---
$aux_dir = './build/aux';
$out_dir = './build/out';

# --- If latexmk was called with -auxdir/-outdir, use those values ---
for (my $i = 0; $i < @ARGV; $i++) {
  if ($ARGV[$i] eq '-auxdir' && defined $ARGV[$i+1]) {
    $aux_dir = $ARGV[$i+1];
  }
  if ($ARGV[$i] eq '-outdir' && defined $ARGV[$i+1]) {
    $out_dir = $ARGV[$i+1];
  }
}

# --- Engine defaults ---
$pdf_mode = 1;          # 1=pdflatex, 4=lualatex, 5=xelatex
$pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 %O %S';
$lualatex = 'lualatex -interaction=nonstopmode -synctex=1 %O %S';
$xelatex  = 'xelatex  -interaction=nonstopmode -synctex=1 %O %S';

# --- Biber integration ---
# With emulate-aux-dir, latexmk expects .bbl in the AUX dir.
add_cus_dep('bcf', 'bbl', 0, 'biber_aux');

sub biber_aux {
  print STDERR "\n==== RUNNING GLOBAL BIBER ====\n";
  print STDERR "Aux dir : $aux_dir\n";
  print STDERR "Out dir : $out_dir\n";
  print STDERR "Command : biber --input-directory=$aux_dir --output-directory=$aux_dir @_\n\n";

  system("biber --input-directory=$aux_dir --output-directory=$aux_dir @_");
}

# Make sure latexmk uses Biber for bibtex commands too
$bibtex = "biber --input-directory=$aux_dir --output-directory=$aux_dir %B";

# --- Robustness ---
$max_repeat  = 8;   # allow plenty of passes for xrefs
$diagnostics = 1;   # show file destinations in logs

# --- Cleaning rules ---
push @clean_ext, qw(
  aux bbl bcf blg fdb_latexmk fls lof log lot
  nav out run.xml snm synctex.gz toc vrb
);
push @clean_full_ext, qw(
  bbl bcf blg pdf
);

# --- Optional shell-escape ---
# $pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 -shell-escape %O %S';
# $lualatex = 'lualatex -interaction=nonstopmode -synctex=1 -shell-escape %O %S';
# $xelatex  = 'xelatex  -interaction=nonstopmode -synctex=1 -shell-escape %O %S';
