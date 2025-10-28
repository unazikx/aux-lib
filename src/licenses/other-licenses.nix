lib: {
  acsl14 = lib.licenses.mkLicense {
    fullName = "Anti-Capitalist Software License v1.4";
    urls = [ "https://anticapitalist.software/" ];
    # restrictions on corporations apply for both use and redistribution
    free = false;
    redistributable = false;
  };

  activision = lib.licenses.mkLicense {
    # https://doomwiki.org/wiki/Raven_source_code_licensing
    fullName = "Activision EULA";
    urls = [ "https://www.doomworld.com/eternity/activision_eula.txt" ];
  };

  amazonsl = lib.licenses.mkLicense {
    fullName = "Amazon Software License";
    urls = [ "https://aws.amazon.com/asl/" ];
  };

  amd = lib.licenses.mkLicense {
    fullName = "AMD License Agreement";
    urls = [ "https://developer.amd.com/amd-license-agreement/" ];
  };

  aom = lib.licenses.mkLicense {
    fullName = "Alliance for Open Media Patent License 1.0";
    urls = [ "https://aomedia.org/license/patent-license/" ];
    free = true; # ?
  };

  bola11 = lib.licenses.mkLicense {
    fullName = "Buena Onda License Agreement 1.1";
    urls = [ "https://blitiri.com.ar/p/bola/" ];
    free = true; # ?
  };

  caossl = lib.licenses.mkLicense {
    fullName = "Computer Associates Open Source Licence Version 1.0";
    urls = [ "http://jxplorer.org/licence.html" ];
    free = true; # ?
  };

  capec = lib.licenses.mkLicense {
    fullName = "Common Attack Pattern Enumeration and Classification";
    urls = [ "https://capec.mitre.org/about/termsofuse.html" ];
    free = true;
  };
}
