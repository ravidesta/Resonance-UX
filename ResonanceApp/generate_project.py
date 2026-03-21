#!/usr/bin/env python3
"""
Generate Resonance.xcodeproj/project.pbxproj
Resonance — Design for the Exhale

Two targets:
  1. Resonance (iOS / iPadOS / macOS / visionOS — multiplatform)
  2. Resonance Watch App (watchOS)

All Swift files are included in both targets. The #if os() guards
ensure only platform-appropriate code compiles for each destination.
"""

import hashlib
import os

# ── UUID Generation ──

def make_uuid(seed: str) -> str:
    """Generate a deterministic 24-char hex UUID from a seed string."""
    return hashlib.md5(seed.encode()).hexdigest()[:24].upper()

# ── File Inventory ──

# (path_from_ResonanceApp, display_name, is_swift)
ALL_FILES = [
    # Design System
    ("Shared/DesignSystem/GlassMorphismModifier.swift", "GlassMorphismModifier.swift", True),
    ("Shared/DesignSystem/OrganicBlobView.swift", "OrganicBlobView.swift", True),
    ("Shared/DesignSystem/ResonanceAnimations.swift", "ResonanceAnimations.swift", True),
    ("Shared/DesignSystem/ResonanceTheme.swift", "ResonanceTheme.swift", True),
    ("Shared/DesignSystem/ResonanceTypography.swift", "ResonanceTypography.swift", True),
    # Models
    ("Shared/Models/Contact.swift", "Contact.swift", True),
    ("Shared/Models/DailyPhase.swift", "DailyPhase.swift", True),
    ("Shared/Models/Document.swift", "Document.swift", True),
    ("Shared/Models/TaskItem.swift", "TaskItem.swift", True),
    # ViewModels
    ("Shared/ViewModels/DailyFlowViewModel.swift", "DailyFlowViewModel.swift", True),
    ("Shared/ViewModels/TaskViewModel.swift", "TaskViewModel.swift", True),
    ("Shared/ViewModels/WriterViewModel.swift", "WriterViewModel.swift", True),
    # Views/Components
    ("Shared/Views/Components/DeepRestToggle.swift", "DeepRestToggle.swift", True),
    # Views
    ("Shared/Views/DailyFlow/DailyFlowView.swift", "DailyFlowView.swift", True),
    ("Shared/Views/Focus/FocusView.swift", "FocusView.swift", True),
    ("Shared/Views/Writer/WriterView.swift", "WriterView.swift", True),
    ("Shared/Views/InnerCircle/InnerCircleView.swift", "InnerCircleView.swift", True),
    # Root
    ("Shared/ContentView.swift", "ContentView.swift", True),
    # Platform entry points
    ("iOS/ResonanceApp_iOS.swift", "ResonanceApp_iOS.swift", True),
    ("macOS/ResonanceApp_macOS.swift", "ResonanceApp_macOS.swift", True),
    ("watchOS/ResonanceApp_watchOS.swift", "ResonanceApp_watchOS.swift", True),
    ("watchOS/WatchViews/WatchDailyFlowView.swift", "WatchDailyFlowView.swift", True),
    ("watchOS/WatchViews/WatchTaskView.swift", "WatchTaskView.swift", True),
    ("watchOS/WatchViews/WatchBreathingView.swift", "WatchBreathingView.swift", True),
    ("watchOS/WatchViews/ComplicationViews.swift", "ComplicationViews.swift", True),
    ("visionOS/ResonanceApp_visionOS.swift", "ResonanceApp_visionOS.swift", True),
    ("visionOS/VisionViews/ImmersiveWriterView.swift", "ImmersiveWriterView.swift", True),
    ("visionOS/VisionViews/SpatialDailyFlowView.swift", "SpatialDailyFlowView.swift", True),
    # Widgets (not compiled in app targets, for reference only)
    ("Widgets/ResonanceWidgets.swift", "ResonanceWidgets.swift", True),
]

SWIFT_FILES = [f for f in ALL_FILES if f[2] and "Widgets/" not in f[0]]
WIDGET_FILES = [f for f in ALL_FILES if "Widgets/" in f[0]]

# ── UUIDs ──

# File references
file_ref = {f[0]: make_uuid(f"fileref_{f[0]}") for f in ALL_FILES}

# Build files (main target)
bf_main = {f[0]: make_uuid(f"bf_main_{f[0]}") for f in SWIFT_FILES}

# Build files (watch target)
bf_watch = {f[0]: make_uuid(f"bf_watch_{f[0]}") for f in SWIFT_FILES}

# Assets
ASSETS_REF = make_uuid("fileref_assets")
ASSETS_BF_MAIN = make_uuid("bf_main_assets")
ASSETS_BF_WATCH = make_uuid("bf_watch_assets")
INFO_PLIST_REF = make_uuid("fileref_info_plist")

# Groups
GRP_ROOT = make_uuid("group_root")
GRP_SHARED = make_uuid("group_shared")
GRP_DESIGN = make_uuid("group_designsystem")
GRP_MODELS = make_uuid("group_models")
GRP_VIEWMODELS = make_uuid("group_viewmodels")
GRP_VIEWS = make_uuid("group_views")
GRP_COMPONENTS = make_uuid("group_components")
GRP_DAILYFLOW = make_uuid("group_dailyflow")
GRP_FOCUS = make_uuid("group_focus")
GRP_WRITER = make_uuid("group_writer")
GRP_INNERCIRCLE = make_uuid("group_innercircle")
GRP_IOS = make_uuid("group_ios")
GRP_MACOS = make_uuid("group_macos")
GRP_WATCHOS = make_uuid("group_watchos")
GRP_WATCHVIEWS = make_uuid("group_watchviews")
GRP_VISIONOS = make_uuid("group_visionos")
GRP_VISIONVIEWS = make_uuid("group_visionviews")
GRP_WIDGETS = make_uuid("group_widgets")
GRP_ASSETS = make_uuid("group_assets")
GRP_PRODUCTS = make_uuid("group_products")
GRP_FRAMEWORKS = make_uuid("group_frameworks")

# Targets
TGT_MAIN = make_uuid("target_main")
TGT_WATCH = make_uuid("target_watch")

# Products
PROD_MAIN = make_uuid("product_main")
PROD_WATCH = make_uuid("product_watch")

# Build phases
BP_MAIN_SOURCES = make_uuid("bp_main_sources")
BP_MAIN_RESOURCES = make_uuid("bp_main_resources")
BP_MAIN_FRAMEWORKS = make_uuid("bp_main_frameworks")
BP_WATCH_SOURCES = make_uuid("bp_watch_sources")
BP_WATCH_RESOURCES = make_uuid("bp_watch_resources")
BP_WATCH_FRAMEWORKS = make_uuid("bp_watch_frameworks")

# Configurations
CFG_PROJ_DEBUG = make_uuid("cfg_proj_debug")
CFG_PROJ_RELEASE = make_uuid("cfg_proj_release")
CFG_MAIN_DEBUG = make_uuid("cfg_main_debug")
CFG_MAIN_RELEASE = make_uuid("cfg_main_release")
CFG_WATCH_DEBUG = make_uuid("cfg_watch_debug")
CFG_WATCH_RELEASE = make_uuid("cfg_watch_release")

# Config lists
CFGLIST_PROJ = make_uuid("cfglist_proj")
CFGLIST_MAIN = make_uuid("cfglist_main")
CFGLIST_WATCH = make_uuid("cfglist_watch")

# Project
PROJECT = make_uuid("project_root")

# ── Generate pbxproj ──

def gen():
    lines = []
    w = lines.append

    w("// !$*UTF8*$!")
    w("{")
    w("\tarchiveVersion = 1;")
    w("\tclasses = {")
    w("\t};")
    w("\tobjectVersion = 77;")
    w(f"\trootObject = {PROJECT};")
    w("\tobjects = {")
    w("")

    # ── PBXBuildFile ──
    w("/* Begin PBXBuildFile section */")
    for f in SWIFT_FILES:
        w(f"\t\t{bf_main[f[0]]} /* {f[1]} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref[f[0]]}; }};")
    w(f"\t\t{ASSETS_BF_MAIN} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {ASSETS_REF}; }};")
    for f in SWIFT_FILES:
        w(f"\t\t{bf_watch[f[0]]} /* {f[1]} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref[f[0]]}; }};")
    w(f"\t\t{ASSETS_BF_WATCH} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {ASSETS_REF}; }};")
    w("/* End PBXBuildFile section */")
    w("")

    # ── PBXFileReference ──
    w("/* Begin PBXFileReference section */")
    for f in ALL_FILES:
        w(f'\t\t{file_ref[f[0]]} /* {f[1]} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{f[1]}"; sourceTree = "<group>"; }};')
    w(f'\t\t{ASSETS_REF} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};')
    w(f'\t\t{INFO_PLIST_REF} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};')
    w(f'\t\t{PROD_MAIN} /* Resonance.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Resonance.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
    w(f'\t\t{PROD_WATCH} /* Resonance Watch App.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "Resonance Watch App.app"; sourceTree = BUILT_PRODUCTS_DIR; }};')
    w("/* End PBXFileReference section */")
    w("")

    # ── PBXGroup ──
    w("/* Begin PBXGroup section */")

    # Root group
    root_children = [GRP_SHARED, GRP_IOS, GRP_MACOS, GRP_WATCHOS, GRP_VISIONOS, GRP_WIDGETS, ASSETS_REF, INFO_PLIST_REF, GRP_PRODUCTS, GRP_FRAMEWORKS]
    w(f"\t\t{GRP_ROOT} = {{")
    w("\t\t\tisa = PBXGroup;")
    w("\t\t\tchildren = (")
    for c in root_children:
        w(f"\t\t\t\t{c},")
    w("\t\t\t);")
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # Products group
    w(f"\t\t{GRP_PRODUCTS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({PROD_MAIN}, {PROD_WATCH},);")
    w('\t\t\tname = Products;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # Frameworks group
    w(f"\t\t{GRP_FRAMEWORKS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w("\t\t\tchildren = ();")
    w('\t\t\tname = Frameworks;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # Shared group
    shared_children = [GRP_DESIGN, GRP_MODELS, GRP_VIEWMODELS, GRP_VIEWS, file_ref["Shared/ContentView.swift"]]
    w(f"\t\t{GRP_SHARED} = {{")
    w("\t\t\tisa = PBXGroup;")
    w("\t\t\tchildren = (")
    for c in shared_children:
        w(f"\t\t\t\t{c},")
    w("\t\t\t);")
    w('\t\t\tpath = Shared;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # Design System
    ds_files = [f for f in ALL_FILES if "DesignSystem/" in f[0]]
    w(f"\t\t{GRP_DESIGN} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({', '.join(file_ref[f[0]] for f in ds_files)},);")
    w('\t\t\tpath = DesignSystem;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # Models
    m_files = [f for f in ALL_FILES if "Models/" in f[0]]
    w(f"\t\t{GRP_MODELS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({', '.join(file_ref[f[0]] for f in m_files)},);")
    w('\t\t\tpath = Models;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # ViewModels
    vm_files = [f for f in ALL_FILES if "ViewModels/" in f[0]]
    w(f"\t\t{GRP_VIEWMODELS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({', '.join(file_ref[f[0]] for f in vm_files)},);")
    w('\t\t\tpath = ViewModels;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # Views group
    views_children = [GRP_COMPONENTS, GRP_DAILYFLOW, GRP_FOCUS, GRP_WRITER, GRP_INNERCIRCLE]
    w(f"\t\t{GRP_VIEWS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({', '.join(str(c) for c in views_children)},);")
    w('\t\t\tpath = Views;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # Components
    w(f"\t\t{GRP_COMPONENTS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({file_ref['Shared/Views/Components/DeepRestToggle.swift']},);")
    w('\t\t\tpath = Components;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # DailyFlow
    w(f"\t\t{GRP_DAILYFLOW} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({file_ref['Shared/Views/DailyFlow/DailyFlowView.swift']},);")
    w('\t\t\tpath = DailyFlow;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # Focus
    w(f"\t\t{GRP_FOCUS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({file_ref['Shared/Views/Focus/FocusView.swift']},);")
    w('\t\t\tpath = Focus;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # Writer
    w(f"\t\t{GRP_WRITER} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({file_ref['Shared/Views/Writer/WriterView.swift']},);")
    w('\t\t\tpath = Writer;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # InnerCircle
    w(f"\t\t{GRP_INNERCIRCLE} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({file_ref['Shared/Views/InnerCircle/InnerCircleView.swift']},);")
    w('\t\t\tpath = InnerCircle;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # iOS
    w(f"\t\t{GRP_IOS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({file_ref['iOS/ResonanceApp_iOS.swift']},);")
    w('\t\t\tpath = iOS;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # macOS
    w(f"\t\t{GRP_MACOS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({file_ref['macOS/ResonanceApp_macOS.swift']},);")
    w('\t\t\tpath = macOS;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # watchOS
    w(f"\t\t{GRP_WATCHOS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({file_ref['watchOS/ResonanceApp_watchOS.swift']}, {GRP_WATCHVIEWS},);")
    w('\t\t\tpath = watchOS;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    wv_files = [f for f in ALL_FILES if "WatchViews/" in f[0]]
    w(f"\t\t{GRP_WATCHVIEWS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({', '.join(file_ref[f[0]] for f in wv_files)},);")
    w('\t\t\tpath = WatchViews;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # visionOS
    w(f"\t\t{GRP_VISIONOS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({file_ref['visionOS/ResonanceApp_visionOS.swift']}, {GRP_VISIONVIEWS},);")
    w('\t\t\tpath = visionOS;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    vv_files = [f for f in ALL_FILES if "VisionViews/" in f[0]]
    w(f"\t\t{GRP_VISIONVIEWS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({', '.join(file_ref[f[0]] for f in vv_files)},);")
    w('\t\t\tpath = VisionViews;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    # Widgets
    w(f"\t\t{GRP_WIDGETS} = {{")
    w("\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = ({file_ref['Widgets/ResonanceWidgets.swift']},);")
    w('\t\t\tpath = Widgets;')
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

    w("/* End PBXGroup section */")
    w("")

    # ── PBXNativeTarget ──
    w("/* Begin PBXNativeTarget section */")

    # Main target
    w(f"\t\t{TGT_MAIN} = {{")
    w("\t\t\tisa = PBXNativeTarget;")
    w(f"\t\t\tbuildConfigurationList = {CFGLIST_MAIN};")
    w(f"\t\t\tbuildPhases = ({BP_MAIN_SOURCES}, {BP_MAIN_FRAMEWORKS}, {BP_MAIN_RESOURCES},);")
    w("\t\t\tbuildRules = ();")
    w(f"\t\t\tdependencies = ();")
    w('\t\t\tname = Resonance;')
    w(f"\t\t\tproductName = Resonance;")
    w(f"\t\t\tproductReference = {PROD_MAIN};")
    w('\t\t\tproductType = "com.apple.product-type.application";')
    w("\t\t};")

    # Watch target
    w(f"\t\t{TGT_WATCH} = {{")
    w("\t\t\tisa = PBXNativeTarget;")
    w(f"\t\t\tbuildConfigurationList = {CFGLIST_WATCH};")
    w(f"\t\t\tbuildPhases = ({BP_WATCH_SOURCES}, {BP_WATCH_FRAMEWORKS}, {BP_WATCH_RESOURCES},);")
    w("\t\t\tbuildRules = ();")
    w(f"\t\t\tdependencies = ();")
    w('\t\t\tname = "Resonance Watch App";')
    w('\t\t\tproductName = "Resonance Watch App";')
    w(f"\t\t\tproductReference = {PROD_WATCH};")
    w('\t\t\tproductType = "com.apple.product-type.application";')
    w("\t\t};")

    w("/* End PBXNativeTarget section */")
    w("")

    # ── PBXProject ──
    w("/* Begin PBXProject section */")
    w(f"\t\t{PROJECT} = {{")
    w("\t\t\tisa = PBXProject;")
    w(f"\t\t\tbuildConfigurationList = {CFGLIST_PROJ};")
    w("\t\t\tcompatibilityVersion = \"Xcode 16.0\";")
    w("\t\t\tdevelopmentRegion = en;")
    w("\t\t\thasScannedForEncodings = 0;")
    w("\t\t\tknownRegions = (en, Base,);")
    w(f"\t\t\tmainGroup = {GRP_ROOT};")
    w(f"\t\t\tproductRefGroup = {GRP_PRODUCTS};")
    w("\t\t\tprojectDirPath = \"\";")
    w('\t\t\tprojectRoot = "";')
    w(f"\t\t\ttargets = ({TGT_MAIN}, {TGT_WATCH},);")
    w("\t\t};")
    w("/* End PBXProject section */")
    w("")

    # ── PBXSourcesBuildPhase ──
    w("/* Begin PBXSourcesBuildPhase section */")

    # Main target sources
    w(f"\t\t{BP_MAIN_SOURCES} = {{")
    w("\t\t\tisa = PBXSourcesBuildPhase;")
    w("\t\t\tbuildActionMask = 2147483647;")
    w("\t\t\tfiles = (")
    for f in SWIFT_FILES:
        w(f"\t\t\t\t{bf_main[f[0]]},")
    w("\t\t\t);")
    w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    w("\t\t};")

    # Watch target sources
    w(f"\t\t{BP_WATCH_SOURCES} = {{")
    w("\t\t\tisa = PBXSourcesBuildPhase;")
    w("\t\t\tbuildActionMask = 2147483647;")
    w("\t\t\tfiles = (")
    for f in SWIFT_FILES:
        w(f"\t\t\t\t{bf_watch[f[0]]},")
    w("\t\t\t);")
    w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    w("\t\t};")

    w("/* End PBXSourcesBuildPhase section */")
    w("")

    # ── PBXResourcesBuildPhase ──
    w("/* Begin PBXResourcesBuildPhase section */")

    w(f"\t\t{BP_MAIN_RESOURCES} = {{")
    w("\t\t\tisa = PBXResourcesBuildPhase;")
    w("\t\t\tbuildActionMask = 2147483647;")
    w(f"\t\t\tfiles = ({ASSETS_BF_MAIN},);")
    w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    w("\t\t};")

    w(f"\t\t{BP_WATCH_RESOURCES} = {{")
    w("\t\t\tisa = PBXResourcesBuildPhase;")
    w("\t\t\tbuildActionMask = 2147483647;")
    w(f"\t\t\tfiles = ({ASSETS_BF_WATCH},);")
    w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    w("\t\t};")

    w("/* End PBXResourcesBuildPhase section */")
    w("")

    # ── PBXFrameworksBuildPhase ──
    w("/* Begin PBXFrameworksBuildPhase section */")

    w(f"\t\t{BP_MAIN_FRAMEWORKS} = {{")
    w("\t\t\tisa = PBXFrameworksBuildPhase;")
    w("\t\t\tbuildActionMask = 2147483647;")
    w("\t\t\tfiles = ();")
    w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    w("\t\t};")

    w(f"\t\t{BP_WATCH_FRAMEWORKS} = {{")
    w("\t\t\tisa = PBXFrameworksBuildPhase;")
    w("\t\t\tbuildActionMask = 2147483647;")
    w("\t\t\tfiles = ();")
    w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    w("\t\t};")

    w("/* End PBXFrameworksBuildPhase section */")
    w("")

    # ── XCBuildConfiguration ──
    w("/* Begin XCBuildConfiguration section */")

    # -- Project Debug --
    w(f"\t\t{CFG_PROJ_DEBUG} = {{")
    w("\t\t\tisa = XCBuildConfiguration;")
    w("\t\t\tbuildSettings = {")
    w("\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;")
    w('\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
    w('\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
    w('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
    w('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
    w('\t\t\t\tCOPY_PHASE_STRIP = NO;')
    w('\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;')
    w('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
    w('\t\t\t\tENABLE_TESTABILITY = YES;')
    w('\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = YES;')
    w('\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;')
    w('\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;')
    w('\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;')
    w('\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ("DEBUG=1", "$(inherited)",);')
    w('\t\t\t\tLOCALIZATION_PREFERS_STRING_CATALOGS = YES;')
    w('\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;')
    w('\t\t\t\tMTL_FAST_MATH = YES;')
    w('\t\t\t\tONLY_ACTIVE_ARCH = YES;')
    w('\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";')
    w('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
    w('\t\t\t\tSWIFT_VERSION = 6.0;')
    w("\t\t\t};")
    w('\t\t\tname = Debug;')
    w("\t\t};")

    # -- Project Release --
    w(f"\t\t{CFG_PROJ_RELEASE} = {{")
    w("\t\t\tisa = XCBuildConfiguration;")
    w("\t\t\tbuildSettings = {")
    w("\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;")
    w('\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
    w('\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
    w('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
    w('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
    w('\t\t\t\tCOPY_PHASE_STRIP = NO;')
    w('\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
    w('\t\t\t\tENABLE_NS_ASSERTIONS = NO;')
    w('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
    w('\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = YES;')
    w('\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;')
    w('\t\t\t\tLOCALIZATION_PREFERS_STRING_CATALOGS = YES;')
    w('\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;')
    w('\t\t\t\tMTL_FAST_MATH = YES;')
    w('\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;')
    w('\t\t\t\tSWIFT_VERSION = 6.0;')
    w("\t\t\t};")
    w('\t\t\tname = Release;')
    w("\t\t};")

    # -- Main Target Debug --
    w(f"\t\t{CFG_MAIN_DEBUG} = {{")
    w("\t\t\tisa = XCBuildConfiguration;")
    w("\t\t\tbuildSettings = {")
    w('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
    w('\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
    w('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
    w('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
    w('\t\t\t\tDEVELOPMENT_TEAM = "";')
    w('\t\t\t\tENABLE_PREVIEWS = YES;')
    w('\t\t\t\tGENERATE_INFOPLIST_FILE = YES;')
    w('\t\t\t\tINFOPLIST_FILE = Info.plist;')
    w('\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = Resonance;')
    w('\t\t\t\tINFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.lifestyle";')
    w('\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;')
    w('\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
    w('\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;')
    w('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";')
    w('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = UIInterfaceOrientationPortrait;')
    w('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;')
    w('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks",);')
    w('\t\t\t\tMACOSX_DEPLOYMENT_TARGET = 15.0;')
    w('\t\t\t\tMARKETING_VERSION = 1.0;')
    w('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.resonance.app;')
    w('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    w('\t\t\t\tSDKROOT = auto;')
    w('\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx xros xrsimulator";')
    w('\t\t\t\tSUPPORTS_MACCATALYST = NO;')
    w('\t\t\t\tSUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO;')
    w('\t\t\t\tSUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD = NO;')
    w('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
    w('\t\t\t\tSWIFT_STRICT_CONCURRENCY = complete;')
    w('\t\t\t\tSWIFT_VERSION = 6.0;')
    w('\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2,7";')
    w('\t\t\t\tXROS_DEPLOYMENT_TARGET = 2.0;')
    w("\t\t\t};")
    w('\t\t\tname = Debug;')
    w("\t\t};")

    # -- Main Target Release --
    w(f"\t\t{CFG_MAIN_RELEASE} = {{")
    w("\t\t\tisa = XCBuildConfiguration;")
    w("\t\t\tbuildSettings = {")
    w('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
    w('\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
    w('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
    w('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
    w('\t\t\t\tDEVELOPMENT_TEAM = "";')
    w('\t\t\t\tENABLE_PREVIEWS = YES;')
    w('\t\t\t\tGENERATE_INFOPLIST_FILE = YES;')
    w('\t\t\t\tINFOPLIST_FILE = Info.plist;')
    w('\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = Resonance;')
    w('\t\t\t\tINFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.lifestyle";')
    w('\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;')
    w('\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
    w('\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;')
    w('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";')
    w('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = UIInterfaceOrientationPortrait;')
    w('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;')
    w('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks",);')
    w('\t\t\t\tMACOSX_DEPLOYMENT_TARGET = 15.0;')
    w('\t\t\t\tMARKETING_VERSION = 1.0;')
    w('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.resonance.app;')
    w('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    w('\t\t\t\tSDKROOT = auto;')
    w('\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx xros xrsimulator";')
    w('\t\t\t\tSUPPORTS_MACCATALYST = NO;')
    w('\t\t\t\tSUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO;')
    w('\t\t\t\tSUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD = NO;')
    w('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
    w('\t\t\t\tSWIFT_STRICT_CONCURRENCY = complete;')
    w('\t\t\t\tSWIFT_VERSION = 6.0;')
    w('\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2,7";')
    w('\t\t\t\tXROS_DEPLOYMENT_TARGET = 2.0;')
    w("\t\t\t};")
    w('\t\t\tname = Release;')
    w("\t\t};")

    # -- Watch Target Debug --
    w(f"\t\t{CFG_WATCH_DEBUG} = {{")
    w("\t\t\tisa = XCBuildConfiguration;")
    w("\t\t\tbuildSettings = {")
    w('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
    w('\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
    w('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
    w('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
    w('\t\t\t\tDEVELOPMENT_TEAM = "";')
    w('\t\t\t\tENABLE_PREVIEWS = YES;')
    w('\t\t\t\tGENERATE_INFOPLIST_FILE = YES;')
    w('\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = Resonance;')
    w('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown";')
    w('\t\t\t\tINFOPLIST_KEY_WKCompanionAppBundleIdentifier = com.resonance.app;')
    w('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks",);')
    w('\t\t\t\tMARKETING_VERSION = 1.0;')
    w('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.resonance.app.watchkitapp;')
    w('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    w('\t\t\t\tSDKROOT = watchos;')
    w('\t\t\t\tSKIP_INSTALL = YES;')
    w('\t\t\t\tSUPPORTED_PLATFORMS = "watchos watchsimulator";')
    w('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
    w('\t\t\t\tSWIFT_STRICT_CONCURRENCY = complete;')
    w('\t\t\t\tSWIFT_VERSION = 6.0;')
    w('\t\t\t\tTARGETED_DEVICE_FAMILY = 4;')
    w('\t\t\t\tWATCHOS_DEPLOYMENT_TARGET = 11.0;')
    w("\t\t\t};")
    w('\t\t\tname = Debug;')
    w("\t\t};")

    # -- Watch Target Release --
    w(f"\t\t{CFG_WATCH_RELEASE} = {{")
    w("\t\t\tisa = XCBuildConfiguration;")
    w("\t\t\tbuildSettings = {")
    w('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
    w('\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
    w('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
    w('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
    w('\t\t\t\tDEVELOPMENT_TEAM = "";')
    w('\t\t\t\tENABLE_PREVIEWS = YES;')
    w('\t\t\t\tGENERATE_INFOPLIST_FILE = YES;')
    w('\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = Resonance;')
    w('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown";')
    w('\t\t\t\tINFOPLIST_KEY_WKCompanionAppBundleIdentifier = com.resonance.app;')
    w('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks",);')
    w('\t\t\t\tMARKETING_VERSION = 1.0;')
    w('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.resonance.app.watchkitapp;')
    w('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    w('\t\t\t\tSDKROOT = watchos;')
    w('\t\t\t\tSKIP_INSTALL = YES;')
    w('\t\t\t\tSUPPORTED_PLATFORMS = "watchos watchsimulator";')
    w('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
    w('\t\t\t\tSWIFT_STRICT_CONCURRENCY = complete;')
    w('\t\t\t\tSWIFT_VERSION = 6.0;')
    w('\t\t\t\tTARGETED_DEVICE_FAMILY = 4;')
    w('\t\t\t\tWATCHOS_DEPLOYMENT_TARGET = 11.0;')
    w("\t\t\t};")
    w('\t\t\tname = Release;')
    w("\t\t};")

    w("/* End XCBuildConfiguration section */")
    w("")

    # ── XCConfigurationList ──
    w("/* Begin XCConfigurationList section */")

    w(f"\t\t{CFGLIST_PROJ} = {{")
    w("\t\t\tisa = XCConfigurationList;")
    w(f"\t\t\tbuildConfigurations = ({CFG_PROJ_DEBUG}, {CFG_PROJ_RELEASE},);")
    w("\t\t\tdefaultConfigurationIsVisible = 0;")
    w('\t\t\tdefaultConfigurationName = Release;')
    w("\t\t};")

    w(f"\t\t{CFGLIST_MAIN} = {{")
    w("\t\t\tisa = XCConfigurationList;")
    w(f"\t\t\tbuildConfigurations = ({CFG_MAIN_DEBUG}, {CFG_MAIN_RELEASE},);")
    w("\t\t\tdefaultConfigurationIsVisible = 0;")
    w('\t\t\tdefaultConfigurationName = Release;')
    w("\t\t};")

    w(f"\t\t{CFGLIST_WATCH} = {{")
    w("\t\t\tisa = XCConfigurationList;")
    w(f"\t\t\tbuildConfigurations = ({CFG_WATCH_DEBUG}, {CFG_WATCH_RELEASE},);")
    w("\t\t\tdefaultConfigurationIsVisible = 0;")
    w('\t\t\tdefaultConfigurationName = Release;')
    w("\t\t};")

    w("/* End XCConfigurationList section */")
    w("")

    w("\t};")
    w("}")

    return "\n".join(lines)


if __name__ == "__main__":
    content = gen()
    os.makedirs("/home/user/Resonance-UX/ResonanceApp/Resonance.xcodeproj", exist_ok=True)
    with open("/home/user/Resonance-UX/ResonanceApp/Resonance.xcodeproj/project.pbxproj", "w") as f:
        f.write(content)
    print(f"Generated project.pbxproj ({len(content)} bytes)")
    print(f"Targets: Resonance (iOS/iPadOS/macOS/visionOS), Resonance Watch App (watchOS)")
