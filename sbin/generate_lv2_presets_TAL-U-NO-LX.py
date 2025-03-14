#!/usr/bin/python3
# -*- coding: utf-8 -*-
# ********************************************************************
# ZYNTHIAN PROJECT: generate_lv2_presets_TAL-U-NO-LX.py
# 
# Generate LV2 bank/presets for the TAL-U-NO-LX from XML preset collection
# 
# Copyright (C) 2015-2025 Fernando Moyano <jofemodo@zynthian.org>
#
# ********************************************************************
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# For a full copy of the GNU General Public License see the LICENSE.txt file.
# 
# ********************************************************************

import os
import glob
from xml.etree import ElementTree

root_dir = "/root/.toguaudioline/TAL-U-No-LX/presets/"
banks = []
presets = []


def parse_xml_preset(fpath):
        root = ElementTree.parse(fpath)
        for xml_program in root.iter("program"):
                try:
                        return [xml_program.attrib['programname'], xml_program.attrib['category']]
                except Exception as e:
                        print(f"Bad XML preset format '{fpath}' => {e}")


def create_lv2_bank(bank_name):
        n = len(banks)
        banks.append(bank_name)
        # TODO sanitize bank_name
        return f"<https://tal-software.com/TAL-U-NO-LX-V2:bank_{n}>\n" \
                "  a pset:Bank ;\n" \
                "  lv2:appliesTo <https://tal-software.com/TAL-U-NO-LX-V2> ;\n" \
                f"  rdfs:label \"{bank_name}\" .\n\n"


def create_lv2_preset(preset_name, bank_num):
        n = len(presets)
        presets.append(preset_name)
        # TODO sanitize preset_name
        return f"<https://tal-software.com/TAL-U-NO-LX-V2:preset_{n}>\n" \
                "  a pset:Preset ;\n" \
                f"  pset:bank <https://tal-software.com/TAL-U-NO-LX-V2:bank_{bank_num}> ;\n" \
                "  lv2:appliesTo <https://tal-software.com/TAL-U-NO-LX-V2> ;\n" \
                f"  rdfs:label \"{preset_name}\" ;\n" \
                f"  state:state [ <https://tal-software.com/TAL-U-NO-LX-V2:Program> \"{n}\"^^xsd:int ; ] .\n\n"


# Run for every XML preset file and generate TTL
ttl = "@prefix lv2:   <http://lv2plug.in/ns/lv2core#> .\n" \
        "@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .\n" \
        "@prefix pset:  <http://lv2plug.in/ns/ext/presets#> .\n" \
        "@prefix state: <http://lv2plug.in/ns/ext/state#> .\n" \
        "@prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .\n\n\n"

for fpath in sorted(glob.iglob(os.path.join(root_dir, "**"), recursive=True)):
        if os.path.isfile(fpath):
                parts = os.path.splitext(fpath)
                if parts[1] == ".pjunoxl":
                        preset_name, bank_name = parse_xml_preset(fpath)
                        try:
                                bank_num = banks.index(bank_name)
                        except:
                                # Default preset =>
                                if not banks and preset_name == "Default":
                                        bank_name = "None"
                                ttl += create_lv2_bank(bank_name)
                                bank_num = len(banks) - 1
                        #ttl += f"# PRESET '{preset_name}' ('{bank_name}')\n"
                        ttl += create_lv2_preset(preset_name, bank_num)

print(ttl)

# --------------------------------------------------------------------
