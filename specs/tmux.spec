%global debug_package %{nil}
%global __debug_install_post /bin/true

Summary: Terminal multiplexer
Name: tmux
Version: 3.0a
Release: 1%{?dist}
BuildArch: x86_64
License: BSD
Group: Applications/System
URL: https://github.com/tmux/tmux

Source: https://github.com/%{name}/%{name}/releases/download/%{version}/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: ncurses-devel

%if 0%{?el6}
BuildRequires: libevent2-devel
%else
BuildRequires: libevent-devel
%endif

%description
tmux is a "terminal multiplexer". It allows a number of terminals (or windows)
to be accessed and controlled from a single terminal. It is intended to be
a simple, modern, BSD-licensed alternative to programs such as GNU screen.

%prep
#%setup
%setup -q -n tmux-%{version}

%build
%configure
%{__make} %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
%{__make} install DESTDIR="%{buildroot}"
#%{__make} install DESTDIR="%{buildroot}" INSTALLBIN="install -p -m0755" INSTALLMAN="install -p -m0644"
%{__rm} -rf %{buildroot}/lib
# Create the socket dir
%{__install} -d -m0755 %{buildroot}%{_localstatedir}/run/tmux/

%clean
%{__rm} -rf %{buildroot}

%pre
getent group tmux >/dev/null || groupadd -r tmux

%files
%defattr(-, root, root, 0755)
%doc %{_mandir}/man1/tmux.1.*
%attr(2755, root, tmux) %{_bindir}/tmux
%attr(0775, root, tmux) %{_localstatedir}/run/tmux/
