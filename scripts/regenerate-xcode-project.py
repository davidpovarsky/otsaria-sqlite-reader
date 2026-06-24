#!/usr/bin/env python3
from __future__ import annotations

import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT_DIR = ROOT / "OtsariaReader.xcodeproj"
PROJECT_FILE = PROJECT_DIR / "project.pbxproj"
SOURCE_DIR = ROOT / "OtsariaReader"

TARGET_ID = "39CBB80239C4607964ACEB9A"
PROJECT_ID = "5CD759D4193846E4910FD9BB"
MAIN_GROUP_ID = "5C999E731352905727541C3C"
PRODUCTS_GROUP_ID = "6D159F361021D92BC3E10E55"
FILES_GROUP_ID = "AFB6742B3522322D19E795C6"
PRODUCT_FILE_ID = "8781C570CE2D0B6A18F2DECF"
SOURCES_PHASE_ID = "DE6EE531638FBF802B9F50F8"
FRAMEWORKS_PHASE_ID = "36E2D336F4D2831692B077F8"
RESOURCES_PHASE_ID = "505DCE76C480DFFAA8952713"
PROJECT_CONFIG_LIST_ID = "344629A1E4F899A26953FBED"
TARGET_CONFIG_LIST_ID = "BCBA909DEA747C22C71114CD"
PROJECT_DEBUG_CONFIG_ID = "3590F05C2ABF90E768D63BD2"
PROJECT_RELEASE_CONFIG_ID = "FB6B65DE7C93748122CA2848"
TARGET_DEBUG_CONFIG_ID = "2873A659FDF19DF40489ED8D"
TARGET_RELEASE_CONFIG_ID = "6FB96530518CFD57EDFF8597"


def gid(seed: str) -> str:
    return hashlib.sha1(seed.encode("utf-8")).hexdigest()[:24].upper()


def q(value: str) -> str:
    escaped = value.replace('\\', '\\\\').replace('"', '\\"')
    return f'"{escaped}"'


def main() -> None:
    if not SOURCE_DIR.exists():
        raise SystemExit(f"Missing source directory: {SOURCE_DIR}")

    swift_files = sorted(
        path.relative_to(ROOT).as_posix()
        for path in SOURCE_DIR.rglob("*.swift")
    )
    if not swift_files:
        raise SystemExit(f"No Swift files found under {SOURCE_DIR}")

    file_refs = {path: gid(f"file:{path}") for path in swift_files}
    build_files = {path: gid(f"build:{path}") for path in swift_files}

    lines: list[str] = []
    lines.append("// !$*UTF8*$!")
    lines.append("{")
    lines.append("\tarchiveVersion = 1;")
    lines.append("\tclasses = {")
    lines.append("\t};")
    lines.append("\tobjectVersion = 56;")
    lines.append("\tobjects = {")
    lines.append("")

    lines.append("/* Begin PBXBuildFile section */")
    for path in swift_files:
        name = Path(path).name
        lines.append(f"\t\t{build_files[path]} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[path]} /* {name} */; }};")
    lines.append("/* End PBXBuildFile section */")
    lines.append("")

    lines.append("/* Begin PBXFileReference section */")
    lines.append(f"\t\t{PRODUCT_FILE_ID} /* OtsariaReader.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = OtsariaReader.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
    for path in swift_files:
        name = Path(path).name
        lines.append(f"\t\t{file_refs[path]} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {q(path)}; sourceTree = SOURCE_ROOT; }};")
    lines.append("/* End PBXFileReference section */")
    lines.append("")

    lines.append("/* Begin PBXFrameworksBuildPhase section */")
    lines.append(f"\t\t{FRAMEWORKS_PHASE_ID} /* Frameworks */ = {{")
    lines.append("\t\t\tisa = PBXFrameworksBuildPhase;")
    lines.append("\t\t\tbuildActionMask = 2147483647;")
    lines.append("\t\t\tfiles = (")
    lines.append("\t\t\t);")
    lines.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    lines.append("\t\t};")
    lines.append("/* End PBXFrameworksBuildPhase section */")
    lines.append("")

    lines.append("/* Begin PBXGroup section */")
    lines.append(f"\t\t{MAIN_GROUP_ID} = {{")
    lines.append("\t\t\tisa = PBXGroup;")
    lines.append("\t\t\tchildren = (")
    lines.append(f"\t\t\t\t{FILES_GROUP_ID} /* OtsariaReader */,")
    lines.append(f"\t\t\t\t{PRODUCTS_GROUP_ID} /* Products */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tsourceTree = \"<group>\";")
    lines.append("\t\t};")
    lines.append(f"\t\t{FILES_GROUP_ID} /* OtsariaReader */ = {{")
    lines.append("\t\t\tisa = PBXGroup;")
    lines.append("\t\t\tchildren = (")
    for path in swift_files:
        lines.append(f"\t\t\t\t{file_refs[path]} /* {Path(path).name} */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tname = OtsariaReader;")
    lines.append("\t\t\tsourceTree = \"<group>\";")
    lines.append("\t\t};")
    lines.append(f"\t\t{PRODUCTS_GROUP_ID} /* Products */ = {{")
    lines.append("\t\t\tisa = PBXGroup;")
    lines.append("\t\t\tchildren = (")
    lines.append(f"\t\t\t\t{PRODUCT_FILE_ID} /* OtsariaReader.app */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tname = Products;")
    lines.append("\t\t\tsourceTree = \"<group>\";")
    lines.append("\t\t};")
    lines.append("/* End PBXGroup section */")
    lines.append("")

    lines.append("/* Begin PBXNativeTarget section */")
    lines.append(f"\t\t{TARGET_ID} /* OtsariaReader */ = {{")
    lines.append("\t\t\tisa = PBXNativeTarget;")
    lines.append(f"\t\t\tbuildConfigurationList = {TARGET_CONFIG_LIST_ID} /* Build configuration list for PBXNativeTarget \"OtsariaReader\" */;")
    lines.append("\t\t\tbuildPhases = (")
    lines.append(f"\t\t\t\t{SOURCES_PHASE_ID} /* Sources */,")
    lines.append(f"\t\t\t\t{FRAMEWORKS_PHASE_ID} /* Frameworks */,")
    lines.append(f"\t\t\t\t{RESOURCES_PHASE_ID} /* Resources */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tbuildRules = (")
    lines.append("\t\t\t);")
    lines.append("\t\t\tdependencies = (")
    lines.append("\t\t\t);")
    lines.append("\t\t\tname = OtsariaReader;")
    lines.append("\t\t\tproductName = OtsariaReader;")
    lines.append(f"\t\t\tproductReference = {PRODUCT_FILE_ID} /* OtsariaReader.app */;")
    lines.append("\t\t\tproductType = \"com.apple.product-type.application\";")
    lines.append("\t\t};")
    lines.append("/* End PBXNativeTarget section */")
    lines.append("")

    lines.append("/* Begin PBXProject section */")
    lines.append(f"\t\t{PROJECT_ID} /* Project object */ = {{")
    lines.append("\t\t\tisa = PBXProject;")
    lines.append("\t\t\tattributes = {")
    lines.append("\t\t\t\tBuildIndependentTargetsInParallel = 1;")
    lines.append("\t\t\t\tLastSwiftUpdateCheck = 1600;")
    lines.append("\t\t\t\tLastUpgradeCheck = 1600;")
    lines.append("\t\t\t\tTargetAttributes = {")
    lines.append(f"\t\t\t\t\t{TARGET_ID} = {{")
    lines.append("\t\t\t\t\t\tCreatedOnToolsVersion = 16.0;")
    lines.append("\t\t\t\t\t};")
    lines.append("\t\t\t\t};")
    lines.append("\t\t\t};")
    lines.append(f"\t\t\tbuildConfigurationList = {PROJECT_CONFIG_LIST_ID} /* Build configuration list for PBXProject \"OtsariaReader\" */;")
    lines.append("\t\t\tcompatibilityVersion = \"Xcode 14.0\";")
    lines.append("\t\t\tdevelopmentRegion = en;")
    lines.append("\t\t\thasScannedForEncodings = 0;")
    lines.append("\t\t\tknownRegions = (")
    lines.append("\t\t\t\ten,")
    lines.append("\t\t\t\tBase,")
    lines.append("\t\t\t);")
    lines.append(f"\t\t\tmainGroup = {MAIN_GROUP_ID};")
    lines.append(f"\t\t\tproductRefGroup = {PRODUCTS_GROUP_ID} /* Products */;")
    lines.append("\t\t\tprojectDirPath = \"\";")
    lines.append("\t\t\tprojectRoot = \"\";")
    lines.append("\t\t\ttargets = (")
    lines.append(f"\t\t\t\t{TARGET_ID} /* OtsariaReader */,")
    lines.append("\t\t\t);")
    lines.append("\t\t};")
    lines.append("/* End PBXProject section */")
    lines.append("")

    lines.append("/* Begin PBXResourcesBuildPhase section */")
    lines.append(f"\t\t{RESOURCES_PHASE_ID} /* Resources */ = {{")
    lines.append("\t\t\tisa = PBXResourcesBuildPhase;")
    lines.append("\t\t\tbuildActionMask = 2147483647;")
    lines.append("\t\t\tfiles = (")
    lines.append("\t\t\t);")
    lines.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    lines.append("\t\t};")
    lines.append("/* End PBXResourcesBuildPhase section */")
    lines.append("")

    lines.append("/* Begin PBXSourcesBuildPhase section */")
    lines.append(f"\t\t{SOURCES_PHASE_ID} /* Sources */ = {{")
    lines.append("\t\t\tisa = PBXSourcesBuildPhase;")
    lines.append("\t\t\tbuildActionMask = 2147483647;")
    lines.append("\t\t\tfiles = (")
    for path in swift_files:
        lines.append(f"\t\t\t\t{build_files[path]} /* {Path(path).name} in Sources */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    lines.append("\t\t};")
    lines.append("/* End PBXSourcesBuildPhase section */")
    lines.append("")

    lines.append("/* Begin XCBuildConfiguration section */")
    def project_config(config_id: str, name: str) -> None:
        lines.append(f"\t\t{config_id} /* {name} */ = {{")
        lines.append("\t\t\tisa = XCBuildConfiguration;")
        lines.append("\t\t\tbuildSettings = {")
        lines.append("\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;")
        lines.append("\t\t\t\tCLANG_ANALYZER_NONNULL = YES;")
        lines.append("\t\t\t\tCLANG_ENABLE_MODULES = YES;")
        lines.append("\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;")
        lines.append("\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;")
        if name == "Debug":
            lines.append("\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;")
            lines.append("\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;")
            lines.append("\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = \"DEBUG=1 $(inherited)\";")
            lines.append("\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;")
            lines.append("\t\t\t\tONLY_ACTIVE_ARCH = YES;")
            lines.append("\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;")
            lines.append("\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-Onone\";")
        else:
            lines.append("\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;")
            lines.append("\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;")
            lines.append("\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-O\";")
            lines.append("\t\t\t\tVALIDATE_PRODUCT = YES;")
        lines.append("\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;")
        lines.append("\t\t\t\tSDKROOT = iphoneos;")
        lines.append("\t\t\t};")
        lines.append(f"\t\t\tname = {name};")
        lines.append("\t\t};")

    def target_config(config_id: str, name: str) -> None:
        lines.append(f"\t\t{config_id} /* {name} */ = {{")
        lines.append("\t\t\tisa = XCBuildConfiguration;")
        lines.append("\t\t\tbuildSettings = {")
        lines.append("\t\t\t\tCODE_SIGN_STYLE = Automatic;")
        lines.append("\t\t\t\tCURRENT_PROJECT_VERSION = 1;")
        lines.append("\t\t\t\tGENERATE_INFOPLIST_FILE = YES;")
        lines.append("\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = \"Otsaria Reader\";")
        lines.append("\t\t\t\tINFOPLIST_KEY_LSApplicationCategoryType = \"public.app-category.reference\";")
        lines.append("\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;")
        lines.append("\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;")
        lines.append("\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;")
        lines.append("\t\t\t\tMARKETING_VERSION = 0.1.0;")
        lines.append("\t\t\t\tOTHER_LDFLAGS = \"-lsqlite3\";")
        lines.append("\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.goldcreative.otsariareader;")
        lines.append("\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";")
        lines.append("\t\t\t\tSUPPORTED_PLATFORMS = \"iphoneos iphonesimulator\";")
        lines.append("\t\t\t\tSUPPORTS_MACCATALYST = NO;")
        lines.append("\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;")
        lines.append("\t\t\t\tSWIFT_STRICT_CONCURRENCY = minimal;")
        lines.append("\t\t\t\tSWIFT_VERSION = 5.0;")
        lines.append("\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";")
        lines.append("\t\t\t};")
        lines.append(f"\t\t\tname = {name};")
        lines.append("\t\t};")

    project_config(PROJECT_DEBUG_CONFIG_ID, "Debug")
    project_config(PROJECT_RELEASE_CONFIG_ID, "Release")
    target_config(TARGET_DEBUG_CONFIG_ID, "Debug")
    target_config(TARGET_RELEASE_CONFIG_ID, "Release")
    lines.append("/* End XCBuildConfiguration section */")
    lines.append("")

    lines.append("/* Begin XCConfigurationList section */")
    lines.append(f"\t\t{PROJECT_CONFIG_LIST_ID} /* Build configuration list for PBXProject \"OtsariaReader\" */ = {{")
    lines.append("\t\t\tisa = XCConfigurationList;")
    lines.append("\t\t\tbuildConfigurations = (")
    lines.append(f"\t\t\t\t{PROJECT_DEBUG_CONFIG_ID} /* Debug */,")
    lines.append(f"\t\t\t\t{PROJECT_RELEASE_CONFIG_ID} /* Release */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tdefaultConfigurationIsVisible = 0;")
    lines.append("\t\t\tdefaultConfigurationName = Release;")
    lines.append("\t\t};")
    lines.append(f"\t\t{TARGET_CONFIG_LIST_ID} /* Build configuration list for PBXNativeTarget \"OtsariaReader\" */ = {{")
    lines.append("\t\t\tisa = XCConfigurationList;")
    lines.append("\t\t\tbuildConfigurations = (")
    lines.append(f"\t\t\t\t{TARGET_DEBUG_CONFIG_ID} /* Debug */,")
    lines.append(f"\t\t\t\t{TARGET_RELEASE_CONFIG_ID} /* Release */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tdefaultConfigurationIsVisible = 0;")
    lines.append("\t\t\tdefaultConfigurationName = Release;")
    lines.append("\t\t};")
    lines.append("/* End XCConfigurationList section */")
    lines.append("\t};")
    lines.append(f"\trootObject = {PROJECT_ID} /* Project object */;")
    lines.append("}")

    PROJECT_DIR.mkdir(exist_ok=True)
    PROJECT_FILE.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Regenerated {PROJECT_FILE} with {len(swift_files)} Swift files")


if __name__ == "__main__":
    main()
