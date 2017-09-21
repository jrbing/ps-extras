%global debug_package %{nil}
%global __debug_install_post /bin/true

Summary: Minimal file transfer utility
Name: toss
Version: 1.1
Release: 1%{?dist}
License: MIT
Group: Applications/System
URL: https://github.com/zerotier/toss

Source: https://github.com/zerotier/%{name}/archive/%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
Toss is a convenient ultra-minimal command line tool to
send files over LAN, WiFi, and virtual networks.

%prep
%setup

%build
%{__make} %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
%{__mkdir} -p %{buildroot}/usr/local/bin
%{__make} install DESTDIR="%{buildroot}/usr/local/bin"

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
/usr/local/bin/toss
/usr/local/bin/catch
