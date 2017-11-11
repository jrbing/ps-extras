#%define _unpackaged_files_terminate_build 0
#%define debug_package %{nil}
%bcond_with sysvinit
%bcond_without systemd

Summary: Prometheus exporter for machine metrics
Name: node-exporter
Version: 0.15.1
Release: 1%{?dist}
Group: System Environment/Daemons
License: Apache 2.0
URL: https://github.com/prometheus/node_exporter

Source0: https://github.com/prometheus/node_exporter/releases/download/v%{version}/node_exporter-%{version}.linux-amd64.tar.gz
Source1: node_exporter.init
Source2: node_exporter.service
Source3: node_exporter.service
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

Requires(pre): /usr/sbin/useradd
%if %{with sysvinit}
Requires: daemonize
%endif
%if %{with systemd}
Requires(post): systemd
Requires(preun): systemd
Requires(postun): systemd
%endif
AutoReqProv: No

%description
Prometheus exporter for machine metrics.

%prep
%setup -q -n node_exporter-%{version}.linux-amd64

%build
echo

%install
%if %{with sysvinit}
install -d -p   %{buildroot}%{_sbindir} \
                %{buildroot}/etc/init.d \
                %{buildroot}/etc/sysconfig
install -p -m 0644 %{_sourcedir}/node_exporter.sysconfig %{buildroot}/etc/sysconfig/node_exporter
install -p -m 0644 %{_sourcedir}/node_exporter.init %{buildroot}/etc/init.d/node_exporter
install -p -m 0755 node_exporter %{buildroot}%{_sbindir}/node_exporter
%endif
%if %{with systemd}
install -d -p   %{buildroot}%{_sbindir} \
                %{buildroot}/usr/lib/systemd/system \
                %{buildroot}/etc/sysconfig
install -p -m 0644 %{_sourcedir}/node_exporter.sysconfig %{buildroot}/etc/sysconfig/node_exporter
install -p -m 0644 %{_sourcedir}/node_exporter.service %{buildroot}/usr/lib/systemd/system/node_exporter.service
install -p -m 0755 node_exporter %{buildroot}%{_sbindir}/node_exporter
%endif

%clean

%pre
getent group node_exporter > /dev/null || groupadd -r node_exporter
getent passwd node_exporter > /dev/null || \
    useradd -rg node_exporter -d /var/lib/node_exporter -s /sbin/nologin \
            -c "Prometheus node_exporter" node_exporter
mkdir -p /var/lib/node_exporter/textfile_collector

%files
%if %{with sysvinit}
/etc/init.d/node_exporter
#%config(noreplace) %{_sysconfdir}/sysconfig/node_exporter
%endif
%if %{with systemd}
/usr/lib/systemd/system/node_exporter.service
#%config(noreplace) %{_sysconfdir}/sysconfig/node_exporter
%endif
%{_sbindir}/*
