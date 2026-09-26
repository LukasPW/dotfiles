pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Which Linux distribution the shell is running on, read from the
// os-release(5) file that every distro ships.
//
// Parallel to Compositor.qml: the single home for distro branching, so
// nothing else in the shell has to know how os-release is spelled. The only
// consumer today is Modules/Lock/DistroLogo.qml, which draws `logo`.
//
// Quickshell's Singleton (rather than a bare QtObject like Theme.qml and
// Compositor.qml) because this one needs child FileViews, and QtObject has
// no default children property.
Singleton {
    id: root

    // Lowercased `ID=` - "nixos", "arch", "debian", ... Empty string if
    // os-release was missing or unparseable.
    readonly property string id: root._field("ID").toLowerCase()

    // Lowercased `ID_LIKE=`, the space-separated list of distros this one
    // derives from ("ubuntu debian" on Pop!_OS, "fedora" on Amazon Linux).
    // Consulted when `id` has no glyph of its own, so a derivative distro
    // inherits its parent's logo instead of falling all the way to tux.
    readonly property var idLike: root._field("ID_LIKE").toLowerCase().split(/\s+/).filter(part => part.length > 0)

    // "NixOS 26.11 (Zokor)". Not drawn anywhere yet - here because it's the
    // other half of what os-release is for, and parsing it is free.
    readonly property string prettyName: root._field("PRETTY_NAME") || root._field("NAME") || "Linux"

    // Nerd Font glyph for this distro, falling back to tux for anything
    // unrecognized. Private-use codepoint, so it needs a patched font
    // installed to draw at all - see the note in Modules/Lock/DistroLogo.qml.
    readonly property string logo: {
        const exact = root.glyphs[root.id];
        if (exact)
            return exact;

        const ancestor = root.idLike.find(like => root.glyphs[like]);
        return ancestor ? root.glyphs[ancestor] : "\uf31a"; // nf-linux-tux
    }

    // ID -> nf-linux-* glyph. Keys are the literal lowercased `ID=` values
    // distros ship (hence "pop" not "pop_os", "mx" not "mxlinux", "rhel"
    // not "redhat"), so they're matched, not guessed at.
    //
    // This does not need to be exhaustive - ID_LIKE above covers the long
    // tail of respins, so only distros with a glyph of their own belong
    // here. Codepoints were read out of the installed Nerd Font's post
    // table rather than from a chart, and every one is present in the
    // U+F300-F385 nf-linux range.
    readonly property var glyphs: ({
        // Independent
        "nixos": "\uf313",               // nf-linux-nixos
        "debian": "\uf306",              // nf-linux-debian
        "arch": "\uf303",                // nf-linux-archlinux
        "fedora": "\uf30a",              // nf-linux-fedora
        "gentoo": "\uf30d",              // nf-linux-gentoo
        "alpine": "\uf300",              // nf-linux-alpine
        "void": "\uf32e",                // nf-linux-void
        "slackware": "\uf318",           // nf-linux-slackware
        "solus": "\uf32d",               // nf-linux-solus
        "guix": "\uf325",                // nf-linux-gnu_guix
        "mageia": "\uf310",              // nf-linux-mageia
        "openmandriva": "\uf311",        // nf-linux-mandriva
        "aosc": "\uf301",                // nf-linux-aosc
        "openwrt": "\uf382",             // nf-linux-openwrt
        "postmarketos": "\uf374",        // nf-linux-postmarketos
        "qubes": "\uf342",               // nf-linux-qubesos

        // openSUSE ships a distinct ID per edition
        "opensuse": "\uf314",            // nf-linux-opensuse
        "opensuse-tumbleweed": "\uf37d", // nf-linux-tumbleweed
        "opensuse-leap": "\uf37e",       // nf-linux-leap
        "sles": "\uf314",                // nf-linux-opensuse
        "sled": "\uf314",                // nf-linux-opensuse

        // RHEL family
        "rhel": "\uf316",                // nf-linux-redhat
        "centos": "\uf304",              // nf-linux-centos
        "almalinux": "\uf31d",           // nf-linux-almalinux
        "rocky": "\uf32b",               // nf-linux-rocky_linux

        // Arch family
        "manjaro": "\uf312",             // nf-linux-manjaro
        "endeavouros": "\uf322",         // nf-linux-endeavour
        "artix": "\uf31f",               // nf-linux-artix
        "garuda": "\uf337",              // nf-linux-garuda
        "cachyos": "\uf385",             // nf-linux-cachyos
        "arcolinux": "\uf346",           // nf-linux-arcolinux
        "archcraft": "\uf345",           // nf-linux-archcraft
        "archlabs": "\uf31e",            // nf-linux-archlabs
        "parabola": "\uf340",            // nf-linux-parabola
        "hyperbola": "\uf33a",           // nf-linux-hyperbola
        "xerolinux": "\uf34a",           // nf-linux-xerolinux
        "crystal": "\uf348",             // nf-linux-crystal

        // Debian family
        "ubuntu": "\uf31b",              // nf-linux-ubuntu
        "linuxmint": "\uf30e",           // nf-linux-linuxmint
        "elementary": "\uf309",          // nf-linux-elementary
        "pop": "\uf32a",                 // nf-linux-pop_os
        "zorin": "\uf32f",               // nf-linux-zorin
        "kali": "\uf327",                // nf-linux-kali_linux
        "parrot": "\uf329",              // nf-linux-parrot
        "devuan": "\uf307",              // nf-linux-devuan
        "raspbian": "\uf315",            // nf-linux-raspberry_pi
        "mx": "\uf33f",                  // nf-linux-mxlinux
        "deepin": "\uf321",              // nf-linux-deepin
        "neon": "\uf331",                // nf-linux-kde_neon
        "trisquel": "\uf344",            // nf-linux-trisquel
        "tails": "\uf343",               // nf-linux-tails
        "lxle": "\uf33e",                // nf-linux-lxle
        "puppy": "\uf341",               // nf-linux-puppy
        "biglinux": "\uf347",            // nf-linux-biglinux
        "locos": "\uf349",               // nf-linux-locos

        // Fedora family
        "nobara": "\uf380",              // nf-linux-nobara

        // Not Linux, but they ship os-release too
        "freebsd": "\uf30c",             // nf-linux-freebsd
        "openbsd": "\uf328",             // nf-linux-openbsd
        "openindiana": "\uf326",         // nf-linux-illumos
        "darwin": "\uf302",              // nf-linux-apple
        "macos": "\uf302"                // nf-linux-apple
    })

    // Raw os-release contents, parsed on demand by _field() so there's
    // exactly one place that knows the file's syntax.
    //
    // Calling text() is itself what triggers the read: the FileViews below
    // are blockLoading, which makes them load lazily but synchronously, so
    // nothing touches the disk until the first id/logo lookup asks. That
    // rules out the obvious-looking `onLoaded: _text = text()`, which never
    // fires - it waits on a signal that only a text() call would produce.
    //
    // os-release(5) says /etc/os-release is normally a symlink to
    // /usr/lib/os-release, but images exist that ship only the latter. `||`
    // short-circuits, so the second file is only read when the first
    // yields nothing.
    property string _text: etcOsRelease.text() || usrLibOsRelease.text()

    function _field(key) {
        // Lines are KEY=VALUE, with VALUE optionally single- or
        // double-quoted. The ^ anchor is what keeps an "ID" lookup from
        // matching VERSION_ID / BUILD_ID / VARIANT_ID.
        const match = new RegExp("^" + key + "=(.*)$", "m").exec(root._text);
        if (!match)
            return "";

        return match[1].trim().replace(/^(["'])(.*)\1$/, "$2");
    }

    FileView {
        id: etcOsRelease
        path: "/etc/os-release"

        // Blocking, unlike the async sysfs reads in Modules/Brightness.qml:
        // this resolves once at startup and `logo` has to be right on the
        // lock surface's very first frame, rather than visibly swapping out
        // of the tux fallback after the screen is already up.
        blockLoading: true

        // A distro without os-release is a fallback case, not an error worth
        // a line in the shell's log on every launch.
        printErrors: false
    }

    FileView {
        id: usrLibOsRelease
        path: "/usr/lib/os-release"
        blockLoading: true
        printErrors: false
    }
}
