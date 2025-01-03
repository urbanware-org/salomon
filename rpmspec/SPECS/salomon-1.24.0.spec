Name: salomon
Version: 1.24.0
Release: 1
Summary: Easy-to-use log file monitor and analyzer with various highlighting and filtering features
License: MIT
Source0: salomon-release-1.24.0.tar.gz
BuildArch: noarch

%description
Simple log file monitor and analyzer with various highlighting and filtering features which can also be used with other plain (non-binary) text files.

%prep
%setup -q -n salomon-release-1.24.0

%pre

%install
mkdir -p %{buildroot}/opt/salomon
mkdir -p %{buildroot}/usr/local/bin
cp -a * %{buildroot}/opt/salomon
ln -s /opt/salomon/salomon.sh %{buildroot}/usr/local/bin/salomon

mkdir -p %{buildroot}/usr/share/pixmaps
mkdir -p %{buildroot}/usr/share/icons/hicolor/16x16
mkdir -p %{buildroot}/usr/share/icons/hicolor/24x24
mkdir -p %{buildroot}/usr/share/icons/hicolor/32x32
mkdir -p %{buildroot}/usr/share/icons/hicolor/48x48
mkdir -p %{buildroot}/usr/share/icons/hicolor/64x64
mkdir -p %{buildroot}/usr/share/icons/hicolor/96x96
mkdir -p %{buildroot}/usr/share/icons/hicolor/128x128
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256
mkdir -p %{buildroot}/usr/share/icons/hicolor/scalable

cp -a icons/xpm/salomon.xpm %{buildroot}/usr/share/pixmaps/
cp -a icons/xpm/salomon-gray-border.xpm %{buildroot}/usr/share/pixmaps/

cp -a icons/png/salomon_16x16.png %{buildroot}/usr/share/icons/hicolor/16x16/
cp -a icons/png/salomon_24x24.png %{buildroot}/usr/share/icons/hicolor/24x24/
cp -a icons/png/salomon_32x32.png %{buildroot}/usr/share/icons/hicolor/32x32/
cp -a icons/png/salomon_48x48.png %{buildroot}/usr/share/icons/hicolor/48x48/
cp -a icons/png/salomon_64x64.png %{buildroot}/usr/share/icons/hicolor/64x64/
cp -a icons/png/salomon_96x96.png %{buildroot}/usr/share/icons/hicolor/96x96/
cp -a icons/png/salomon_128x128.png %{buildroot}/usr/share/icons/hicolor/128x128/
cp -a icons/png/salomon_256x256.png %{buildroot}/usr/share/icons/hicolor/256x256/

cp -a icons/png/salomon-gray-border_16x16.png %{buildroot}/usr/share/icons/hicolor/16x16/
cp -a icons/png/salomon-gray-border_24x24.png %{buildroot}/usr/share/icons/hicolor/24x24/
cp -a icons/png/salomon-gray-border_32x32.png %{buildroot}/usr/share/icons/hicolor/32x32/
cp -a icons/png/salomon-gray-border_48x48.png %{buildroot}/usr/share/icons/hicolor/48x48/
cp -a icons/png/salomon-gray-border_64x64.png %{buildroot}/usr/share/icons/hicolor/64x64/
cp -a icons/png/salomon-gray-border_96x96.png %{buildroot}/usr/share/icons/hicolor/96x96/
cp -a icons/png/salomon-gray-border_128x128.png %{buildroot}/usr/share/icons/hicolor/128x128/
cp -a icons/png/salomon-gray-border_256x256.png %{buildroot}/usr/share/icons/hicolor/256x256/

cp -a icons/svg/salomon.svg %{buildroot}/usr/share/icons/hicolor/scalable/
cp -a icons/svg/salomon-gray-border.svg %{buildroot}/usr/share/icons/hicolor/scalable/

find %{buildroot}/opt/salomon -type d -exec chmod 755 {} \;
find %{buildroot}/opt/salomon -type f -exec chmod 644 {} \;

%post
chmod 755 /opt/salomon/*.sh
chmod 755 /opt/salomon/core/*.sh

%files
%config(noreplace) /opt/salomon/salomon.cfg
%config(noreplace) /opt/salomon/colors/*.cfg
%config(noreplace) /opt/salomon/filters/*.cfg

/opt/salomon
/usr/local/bin/salomon

/usr/share/pixmaps/salomon.xpm
/usr/share/pixmaps/salomon-gray-border.xpm

/usr/share/icons/hicolor/16x16/salomon_16x16.png
/usr/share/icons/hicolor/24x24/salomon_24x24.png
/usr/share/icons/hicolor/32x32/salomon_32x32.png
/usr/share/icons/hicolor/48x48/salomon_48x48.png
/usr/share/icons/hicolor/64x64/salomon_64x64.png
/usr/share/icons/hicolor/96x96/salomon_96x96.png
/usr/share/icons/hicolor/128x128/salomon_128x128.png
/usr/share/icons/hicolor/256x256/salomon_256x256.png

/usr/share/icons/hicolor/16x16/salomon-gray-border_16x16.png
/usr/share/icons/hicolor/24x24/salomon-gray-border_24x24.png
/usr/share/icons/hicolor/32x32/salomon-gray-border_32x32.png
/usr/share/icons/hicolor/48x48/salomon-gray-border_48x48.png
/usr/share/icons/hicolor/64x64/salomon-gray-border_64x64.png
/usr/share/icons/hicolor/96x96/salomon-gray-border_96x96.png
/usr/share/icons/hicolor/128x128/salomon-gray-border_128x128.png
/usr/share/icons/hicolor/256x256/salomon-gray-border_256x256.png

/usr/share/icons/hicolor/scalable/salomon.svg
/usr/share/icons/hicolor/scalable/salomon-gray-border.svg

%preun

%postun

%changelog
* Tue Nov 07 2024 Ralf Kilian <dev@urbanware.org> - 1.24.0-1
- Initial package
