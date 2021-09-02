-- xmobar config used by Vic Fryzel
-- Author: Vic Fryzel
-- https://github.com/vicfryzel/xmonad-config

-- This xmobar config is for a single 4k display (3840x2160) and meant to be
-- used with the stalonetrayrc-single config.
--
-- If you're using a single display with a different resolution, adjust the
-- position argument below using the given calculation.
Config {
    -- Position xmobar along the top, with a stalonetray in the top right.
    -- Add right padding to xmobar to ensure stalonetray and xmobar don't
    -- overlap. stalonetrayrc-single is configured for 12 icons, each 23px
    -- wide.
    -- right_padding = num_icons * icon_size
    -- right_padding = 12 * 23 = 276
    -- Example: position = TopP 0 276
      position = TopP 0 0
    , font = "xft:serif:size=10"
    , bgColor = "#000000"
    , fgColor = "#ffffff"
    , lowerOnStart = False
    , overrideRedirect = False
    , allDesktops = True
    , persistent = True
    , commands =
      [ Run MultiCpu ["-t","Cpu: <total> <total0> <total1> <total2> <total3> <total4> <total5> <total6> <total7>","-L","30","-H","60","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC","-w","3"] 10
      -- , Run Weather "KPAO" ["-t","<tempF>F <skyCondition>","-L","64","-H","77","-n","#CEFFAC","-h","#FFB6B0","-l","#96CBFE"] 36000
      , Run Weather "EDHI" [ "--template", "<skyCondition> | <fc=#4682B4><tempC></fc>°C | <fc=#4682B4><rh></fc>% | <fc=#4682B4><pressure></fc>hPa"
        ] 36000
      , Run Memory ["-t","Mem: <usedratio>%","-H","16384","-L","8192","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10 , Run Swap ["-t","Swap: <usedratio>%","-H","1024","-L","512","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10
      -- network activity monitor (dynamic interface resolution)
      , Run DynNetwork     [ "--template" , "<dev>: <tx>kB/s|<rx>kB/s"
                            , "--Low"      , "1000"       -- units: B/s
                            , "--High"     , "5000"       -- units: B/s
                            , "--low"      , "#CEFFAC"
                            , "--normal"   , "#FFFFCC"
                            , "--high"     , "#FFB6B0"
                            ] 10
      -- , Run Network "enp2s0" ["-t","Net: <rx>, <tx>","-H","200","-L","10","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10

      -- cpu core temperature monitor
      , Run CoreTemp       [ "--template" , "Temp: <core0>°C|<core1>°C"
                            , "--Low"      , "70"        -- units: °C
                            , "--High"     , "80"        -- units: °C
                            , "--low"      , "#CEFFAC"
                            , "--normal"   , "#FFFFCC"
                            , "--high"     , "#FFB6B0"
                            ] 50
      , Run Date "%FT%T%z (W%V-%u)" "date" 10
      -- , Run Com "getMasterVolume" [] "volumelevel" 10
      , Run StdinReader
      , Run MPD [ "-t", "<state>: <artist> - <track>", "-h", "/run/user/1000/mpd.socket" ] 10
      ]
    , sepChar = "%"
    , alignSep = "}{"
    -- , template = "%StdinReader% }{ %mpd%   %dynnetwork%   %multicpu%   %EDHI%   %memory%   %swap%  Vol: <fc=#b2b2ff>%volumelevel%</fc>   <fc=#FFFFCC>%date%</fc>"
    , template = "%StdinReader% }{ %mpd%   %dynnetwork%   %multicpu%   %EDHI%   %memory%   %swap%   <fc=#FFFFCC>%date%</fc>"
}
