-- Wave Link-style application routing for WirePlumber 0.5
-- Routes apps to virtual sinks based on application name, binary, or node name.
-- Unmatched apps go to the "System" sink.
-- Manual moves via pavucontrol/helvum are respected within a session.

lutils = require ("linking-utils")
cutils = require ("common-utils")
log = Log.open_topic ("s-linking")

-- Wine/Proton streams carry application.process.binary on the CLIENT object
-- only, never on the stream node -- so si_props ["application.process.binary"]
-- is nil for them and the "^wine" / "%.exe$" pattern routes below can never
-- fire. Games then fall through to the "System" fallback. This object manager
-- lets us resolve the binary from the client via the node's client.id.
clients_om = ObjectManager { Interest { type = "client" } }
clients_om:activate ()

-- Returns application.process.binary for a stream, looking it up on the owning
-- client when the node itself does not carry it.
local function resolve_binary (si_props)
  local binary = si_props ["application.process.binary"]
  if binary then
    return binary
  end

  local cid = tonumber (si_props ["client.id"])
  if not cid then
    return nil
  end

  local client = clients_om:lookup {
    Constraint { "bound-id", "=", cid, type = "gobject" },
  }
  if not client then
    return nil
  end

  return client.properties ["application.process.binary"]
end

-- Exact match routing table: key = app name/binary, value = sink node.name
local exact_routes = {
  -- Music
  ["spotify"]          = "Music",
  ["Spotify"]          = "Music",
  ["ncspot"]           = "Music",
  ["cmus"]             = "Music",
  ["mpv"]              = "Music",
  ["vlc"]              = "Music",
  ["VLC media player"] = "Music",
  ["Lollypop"]         = "Music",
  ["Amberol"]          = "Music",
  ["rhythmbox"]        = "Music",
  ["clementine"]       = "Music",
  ["strawberry"]       = "Music",
  ["tidal-hifi"]       = "Music",
  ["TIDAL"]            = "Music",

  -- AirPlay
  ["Shairport Sync"]   = "AirPlay",
  ["shairport-sync"]   = "AirPlay",

  -- Browsers
  ["firefox"]          = "Browser",
  ["Firefox"]          = "Browser",
  ["chromium"]         = "Browser",
  ["Chromium"]         = "Browser",
  ["Google Chrome"]    = "Browser",
  ["chrome"]           = "Browser",
  ["google-chrome"]    = "Browser",
  ["Brave"]            = "Browser",
  ["brave"]            = "Browser",
  ["brave-browser"]    = "Browser",
  ["zen"]              = "Browser",
  ["Zen"]              = "Browser",
  ["zen-browser"]      = "Browser",
  ["Zen Browser"]      = "Browser",
  ["zen-bin"]          = "Browser",
  ["vivaldi"]          = "Browser",
  ["Vivaldi"]          = "Browser",
  ["opera"]            = "Browser",
  ["Opera"]            = "Browser",
  ["epiphany"]         = "Browser",
  ["librewolf"]        = "Browser",
  ["LibreWolf"]        = "Browser",
  ["floorp"]           = "Browser",
  ["Floorp"]           = "Browser",
  ["waterfox"]         = "Browser",
  ["Waterfox"]         = "Browser",

  -- Communication
  ["discord"]              = "Comms",
  ["Discord"]              = "Comms",
  ["WebCord"]              = "Comms",
  ["vesktop"]              = "Comms",
  ["Vesktop"]              = "Comms",
  ["TeamSpeak 3"]          = "Comms",
  ["ts3client_linux_amd64"]= "Comms",
  ["Mumble"]               = "Comms",
  ["mumble"]               = "Comms",
  ["zoom"]                 = "Comms",
  ["Zoom"]                 = "Comms",
  ["Zoom Meeting"]         = "Comms",
  ["Signal"]               = "Comms",
  ["signal-desktop"]       = "Comms",
  ["Element"]              = "Comms",
  ["element-desktop"]      = "Comms",
  ["Slack"]                = "Comms",
  ["slack"]                = "Comms",
  ["Microsoft Teams"]      = "Comms",
  ["teams-for-linux"]      = "Comms",

  -- Games (explicit entries)
  ["steam"]       = "Games",
  ["Steam"]       = "Games",
  ["gamescope"]   = "Games",
  ["lutris"]      = "Games",
  ["Lutris"]      = "Games",
  ["heroic"]      = "Games",
  ["Heroic"]      = "Games",
  ["bottles"]     = "Games",
  ["Bottles"]     = "Games",
  ["retroarch"]   = "Games",
  ["RetroArch"]   = "Games",
  ["FMOD Ex App"] = "Games",
  ["mangohud"]    = "Games",
  ["java"]        = "Games",
  ["javaw"]       = "Games",
  ["Minecraft"]   = "Games",
}

-- Pattern match routing: checked if exact match fails
-- Each entry: { pattern, target_sink }
local pattern_routes = {
  -- Wine/Proton binaries (wine64-preloader, wineserver, proton, etc.)
  { "^wine", "Games" },
  { "^proton", "Games" },
  -- Wine/Proton games (binaries ending in .exe)
  { "%.exe$", "Games" },
  -- Steam game processes
  { "^steam_app_", "Games" },
}

-- Default sink for apps that don't match any rule
local default_sink = "System"

SimpleEventHook {
  name = "linking/find-user-target",
  before = "linking/find-defined-target",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-target" },
    },
  },
  execute = function (event)
    local source, om, si, si_props, si_flags, target =
        lutils:unwrap_select_target_event (event)

    -- bypass if target already picked by a higher-priority hook
    if target then
      return
    end

    -- only handle playback streams
    local dominated = cutils.getTargetDirection (si_props)
    if dominated ~= "input" then
      return
    end

    -- Skip loopback playback nodes - they route to the Wave XLR via
    -- target.object in virtual-sinks.conf (handled by find-defined-target)
    local node_name = si_props ["node.name"] or ""
    if node_name:match ("_loopback$") then
      return
    end

    local app_name = si_props ["application.name"]
    local binary = resolve_binary (si_props)
    local media_name = si_props ["media.name"]
    local media_role = si_props ["media.role"]

    -- determine target sink name
    local target_sink = nil

    -- 0. route explicit game role to Games
    if media_role and string.lower (media_role) == "game" then
      target_sink = "Games"
    end

    -- 1. exact match on binary name (checked first because Electron apps
    --    all report application.name as "Chromium", so the binary is more
    --    specific and avoids mis-routing e.g. vesktop → Browser)
    if not target_sink and binary then
      target_sink = exact_routes[binary]
    end

    -- 2. exact match on application.name
    if not target_sink and app_name then
      target_sink = exact_routes[app_name]
    end

    -- 3. exact match on node.name
    if not target_sink and node_name then
      target_sink = exact_routes[node_name]
    end

    -- 4. pattern match on app name and binary
    if not target_sink then
      for _, rule in ipairs (pattern_routes) do
        if (app_name and app_name:match (rule[1])) or
           (binary and binary:match (rule[1])) or
           (node_name and node_name:match (rule[1])) then
          target_sink = rule[2]
          break
        end
      end
    end

    -- 5. fallback to default sink
    if not target_sink then
      target_sink = default_sink
    end

    -- look up the target sink session item
    local target_si = om:lookup {
      type = "SiLinkable",
      Constraint { "node.name", "=", target_sink },
      Constraint { "item.node.direction", "=", "input" },
    }

    if target_si and lutils.canLink (si_props, target_si) then
      log:info (si,
        string.format ("... routing %s (%s) -> %s",
          tostring (app_name or binary or node_name),
          tostring (si_props ["node.id"]),
          target_sink))
      event:set_data ("target", target_si)
    else
      log:warning (si,
        string.format ("... target sink '%s' not found or cannot link for %s",
          target_sink, tostring (app_name or binary or node_name)))
    end
  end
}:register ()
