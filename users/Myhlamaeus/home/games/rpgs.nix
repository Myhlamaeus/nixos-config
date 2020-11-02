{ config, pkgs, lib, ... }:

with lib;

{
  config = {
    programs.morrowind = mkIf config.custom.games.enable {
      enable = true;

      settings = {
        camera = {
          nearClip = 1.0;
          smallFeatureCulling = {
            enable = true;
            pixelSize = 2.0;
          };
          viewingDistance = 6666.0;
          fieldOfView = 90.0;
          firstPersonFieldOfView = 55.0;
        };

        cells = {
          exteriorCellLoadDistance = 1;
          preloading = {
            enable = true;
            threads = 1;
            distanceThreshold = 1000;
            cellCache = {
              min = 12;
              max = 20;
              expiryDelay = 5.0;
            };
            predictionTime = 1.0;
            preloadExteriorGrid = true;
            preloadFastTravel = false;
            preloadDoors = true;
            preloadInstances = true;
          };
          cache = { expiryDelay = 5.0; };
          targetFramerate = 144.0;
          pointerCacheSize = 40;
        };

        terrain = { enableDistantTerrain = true; };

        fog = {
          distant = {
            enable = true;

            land = {
              start = 16384.0;
              end = 40960.0;
            };
            underwater = {
              start = (-4096.0);
              end = 2457.6;
            };
            interior = {
              start = 0.0;
              end = 16384.0;
            };
          };
        };

        map = {
          global = { cellSize = 18; };

          local = {
            hudWidgetSize = 256;
            hudFogOfWar.enable = false;
            resolution = 256;
            widgetSize = 512;
            cellDistance = 1;
          };

          defaultMapMode = "local";
        };

        video = {
          resolution = {
            width = 2560;
            height = 1440;
          };
          enableFullscreen = true;
          antialiasing = {
            enable = true;
            level = 8;
          };
          enableVsync = false;
          framerateLimit = {
            enable = false;
            limit = 144.0;
          };
          screenshot = {
            type = "regular";
            width = null;
            height = null;
            cubemapResolution = null;
          };
        };

        waterShader = {
          enable = true;
          rttSize = 1024;
          refraction = {
            enable = true;
            scale = 1.0;
          };
          enableActorReflection = true;
          smallFeatureCullingPixelSize = 20.0;
        };
      };

      modpacks.totalOverhaul.enable = true;
    };

    custom.games.packages = with pkgs;
      optionals config.custom.x11.enable [ wesnoth ];
  };
}
