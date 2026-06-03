# Custom formats partagés Radarr/Sonarr (ReleaseTitleSpecification, '\b' -> '\\b').
# Langue FR favorisée ; VOSTFR/VFQ + unwanted bloqués (-10000).
# Audio : Atmos `negate` dans les variantes non-Atmos pour ne pas cumuler les scores.
# `score` = 2 profils ; `score_1080p`/`score_2160p` surchargent par résolution.
locals {
  custom_formats = {
    multi = {
      name  = "MULTi"
      score = 100
      specifications = [{
        name           = "MULTi"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\bMULTi\\b"
      }]
    }

    truefrench = {
      name  = "TRUEFRENCH"
      score = 75
      specifications = [{
        name           = "TRUEFRENCH"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\bTRUEFRENCH\\b"
      }]
    }

    french = {
      name  = "FRENCH"
      score = 50
      specifications = [{
        name           = "FRENCH"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\bFRENCH\\b"
      }]
    }

    repack_proper = {
      name  = "Repack/Proper"
      score = 5
      specifications = [{
        name           = "Repack/Proper/Rerip"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(REPACK|PROPER|RERIP)\\b"
      }]
    }

    vostfr = {
      name  = "VOSTFR"
      score = -10000
      specifications = [{
        name           = "VOSTFR / SUBFRENCH"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(VOSTFR|SUBFRENCH|SUBFR)\\b"
      }]
    }

    vfq = {
      name  = "VFQ"
      score = -10000
      specifications = [{
        name           = "VFQ (doublage québécois)"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\bVFQ\\b"
      }]
    }

    br_disk = {
      name  = "BR-DISK"
      score = -10000
      specifications = [{
        name           = "BR-DISK"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(BR.?DISK|COMPLETE.?(UHD.?)?BLU.?RAY|BD(25|50|66|100)|BDMV)\\b"
      }]
    }

    threed = {
      name  = "3D"
      score = -10000
      specifications = [{
        name           = "3D"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(3D|HSBS|H-SBS|HalfSBS|HOU|H-OU|HalfOU)\\b"
      }]
    }

    upscaled = {
      name  = "Upscaled"
      score = -10000
      specifications = [{
        name           = "Upscaled"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(upscale[ds]?|AI.?upscale)\\b"
      }]
    }

    # x265/HEVC : indésirable en 1080p (réencodage), normal en 2160p.
    x265_hd = {
      name        = "x265 (HD)"
      score       = 0
      score_1080p = -10000
      specifications = [{
        name           = "x265 (HD)"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b((x|h)\\.?265|HEVC)\\b"
      }]
    }

    # Regex large (HDR10 inclus) ; HDR10+ cumule son bonus -> HDR10+ (23) > HDR (8).
    hdr = {
      name  = "HDR"
      score = 8
      specifications = [{
        name           = "HDR"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(HDR|HDR10|PQ|HLG)\\b"
      }]
    }

    hdr10plus = {
      name  = "HDR10+"
      score = 15
      specifications = [{
        name           = "HDR10+"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(HDR10\\+|HDR10P|HDR10PLUS)\\b"
      }]
    }

    dolby_vision = {
      name  = "Dolby Vision"
      score = 20
      specifications = [{
        name           = "Dolby Vision"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(DV|DOVI|DOLBY.?VISION)\\b"
      }]
    }

    truehd_atmos = {
      name  = "TrueHD Atmos"
      score = 14
      specifications = [
        {
          name           = "TrueHD"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = true
          value          = "\\bTrue[ ._-]?HD\\b"
        },
        {
          name           = "Atmos"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = true
          value          = "\\bATMOS\\b"
        },
      ]
    }

    dts_x = {
      name  = "DTS-X"
      score = 13
      specifications = [{
        name           = "DTS-X"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\bDTS[ ._-]?X\\b"
      }]
    }

    ddplus_atmos = {
      name  = "DD+ Atmos"
      score = 12
      specifications = [
        {
          name           = "DD+ / E-AC-3"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = true
          value          = "\\b(DDP|EAC3|E[ ._-]?AC[ ._-]?3)\\b"
        },
        {
          name           = "Atmos"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = true
          value          = "\\bATMOS\\b"
        },
      ]
    }

    truehd = {
      name  = "TrueHD"
      score = 10
      specifications = [
        {
          name           = "TrueHD"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = true
          value          = "\\bTrue[ ._-]?HD\\b"
        },
        {
          name           = "Atmos"
          implementation = "ReleaseTitleSpecification"
          negate         = true
          required       = true
          value          = "\\bATMOS\\b"
        },
      ]
    }

    dts_hd_ma = {
      name  = "DTS-HD MA"
      score = 9
      specifications = [{
        name           = "DTS-HD MA"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\bDTS[ ._-]?HD[ ._-]?MA\\b"
      }]
    }

    flac = {
      name  = "FLAC"
      score = 6
      specifications = [{
        name           = "FLAC"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\bFLAC\\b"
      }]
    }

    pcm = {
      name  = "PCM"
      score = 6
      specifications = [{
        name           = "PCM"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(L?PCM)\\b"
      }]
    }

    ddplus = {
      name  = "DD+"
      score = 4
      specifications = [
        {
          name           = "DD+ / E-AC-3"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = true
          value          = "\\b(DDP|EAC3|E[ ._-]?AC[ ._-]?3)\\b"
        },
        {
          name           = "Atmos"
          implementation = "ReleaseTitleSpecification"
          negate         = true
          required       = true
          value          = "\\bATMOS\\b"
        },
      ]
    }

    lq = {
      name  = "LQ"
      score = -10000
      specifications = [
        {
          name           = "Groupes LQ"
          implementation = "ReleaseGroupSpecification"
          negate         = false
          required       = false
          value          = "^(24xHD|41RGB|4K4U|AOC|AROMA|aXXo|AZAZE|BARC0DE|BAUCKLEY|BdC|beAst|BTM|C1NEM4|C4K|CDDHD|CHAOS|CHD|CiNE|COLLECTiVE|CREATiVE24|CrEwSaDe|CTFOH|d3g|DDR|DNL|DRX|E|EPiC|EuReKA|FaNGDiNG0|Feranki1980|FGT|FMD|FRDS|FZHD|GalaxyRG|GHD|GPTHD|HDHUB4U|HDS|HDT|HDTime|HDWinG|iNTENSO|iPlanet|iVy|jennaortega(UHD)?|JFF|KC|KiNGDOM|KIRA|L0SERNIGHT|LAMA|Leffe|Liber8|LiGaS|LUCY|MarkII|MeGusta|Mesc|mHD|mSD|MTeam|MT|MySiLU|NhaNc3|nHD|nikt0|nSD|OFT|PATOMiEL|PRODJi|PSA|PTNK|R&H|RARBG|RDN|Rifftrax|RU4HD|SANTi|Scene|SHD|ShieldBearer|STUTTERSHIT|SUNSCREEN|TBS|TEKNO3D|Tigole|TIKO|VISIONPLUSHDR(-X|1000)?|WAF|WiKi|x0r|YIFY|YTS(.(MX|LT|AG))?|Zeus)$"
        },
        {
          name           = "NoGroup"
          implementation = "ReleaseGroupSpecification"
          negate         = false
          required       = false
          value          = "NoGr(ou)?p"
        },
        {
          name           = "Pahe"
          implementation = "ReleaseGroupSpecification"
          negate         = false
          required       = false
          value          = "Pahe(\\.(ph|in))?\\b"
        },
      ]
    }

    lq_release_title = {
      name  = "LQ (Release Title)"
      score = -10000
      specifications = [
        {
          name           = "Groupes (dans le titre)"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = false
          value          = "\\b(1XBET|BEN[ ._-]THE[ ._-]MEN|Feranki1980|GalaxyRG|READ(\\s|\\.)+NOTE|SWTYBLZ|TeeWee|TEKNO3D|Will1869)\\b"
        },
        {
          name           = "D3US"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = false
          value          = "(-D3US|D3US-)"
        },
        {
          name           = "EVO (hors WEB-DL)"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = false
          value          = "(?<=\\b[12]\\d{3}\\b.*?)(?<!\\b(web[ ._-]?(dl|rip)?).*?)\\b(EVO)\\b"
        },
        {
          name           = "HHWEB (hors MA)"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = false
          value          = "^(?!.*\\bMA\\b.*\\bWEB-?DL\\b).*\\b(HHWEB)\\b"
        },
        {
          name           = "jennaortega"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = false
          value          = "(?<!-)\\b(jennaortega(UHD)?)\\b"
        },
        {
          name           = "PiRaTeS (hors WEB-DL)"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = false
          value          = "(?<=\\b[12]\\d{3}\\b.*?)(?<!\\b(web[ ._-]?(dl|rip)?).*?)\\b(PiRaTeS)\\b"
        },
        {
          name           = "UnKn0wn (hors Remux)"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = false
          value          = "(?<!\\b(remux).*?)\\b(unkn0wn)\\b"
        },
      ]
    }

    obfuscated = {
      name  = "Obfuscated"
      score = -10000
      specifications = [
        {
          name           = "Suffixes obfusqués"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = false
          value          = "-(4P|4Planet|AsRequested|BUYMORE|Chamele0n|GEROV|iNC0GNiTO|NZBGeek|Obfuscated|postbot|Rakuv|WhiteRev|xpost|WRTEAM|CAPTCHA)\\b"
        },
        {
          name           = "_nzb"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = false
          value          = "_nzb\\b"
        },
        {
          name           = "Scrambled"
          implementation = "ReleaseTitleSpecification"
          negate         = false
          required       = false
          value          = "(?<=\\b[12]\\d{3}\\b).*(Scrambled)\\b"
        },
      ]
    }

    retags = {
      name  = "Retags"
      score = -10000
      specifications = [{
        name           = "Retags (post-upload)"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = false
        value          = "(\\[rartv\\]|\\[rarbg\\]|\\[eztvx?[ ._-]?(io|re|to)?\\]|\\[TGx\\]|[.]VAV\\b|[.]heb\\b|\\bORARBG\\b)"
      }]
    }

    bad_dual_groups = {
      name  = "Bad Dual Groups"
      score = -10000
      specifications = [{
        name           = "Mauvais groupes dual-audio"
        implementation = "ReleaseGroupSpecification"
        negate         = false
        required       = false
        value          = "^(alfaHD.*|BAT|BlackBit|BNd|C\\.A\\.A|Cory|CYPHER|EniaHD|EXTREME|FF|FOXX|G4RiS|GUEIRA|LCD|MGE\\b.*|MLH|N3G4N|ONLYMOViE|PD|PTHome|RiPER|RK|SiGLA|Tars|TM\\b|tokar86a|TURG|TvR|vnlls|WTV|XiQUEXiQUE|Yatogam1|YusukeFLA|ZigZag|ZNM)$"
      }]
    }
  }
}
