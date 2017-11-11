
FROM centos:centos7
MAINTAINER JR Bing <jr@jrbing.com>

VOLUME ["/rpmbuild"]
ADD ./scripts/build-rpm.sh /build-rpm.sh

RUN yum clean all && \
  yum -y update && \
  yum -y install epel-release && \
  yum -y install mock rpm-build redhat-rpm-config rpmdevtools nosync lzop pigz lbzip2 && \
  useradd -u 1001 builder && \
  usermod -a -G mock builder && \
  mkdir -p /home/builder/.config && \
  install --group=mock --mode=2775 --directory /rpmbuild/CACHE && \
  chmod +x /build-rpm.sh

ADD ./etc/rpmmacros /home/builder/.rpmmacros
RUN chown builder:builder /home/builder/.rpmmacros

ADD ./etc/mock.cfg /home/builder/.config/mock.cfg
RUN chown -R builder:builder /home/builder/.config

USER builder
ENV HOME /home/builder
CMD ["/build-rpm.sh"]
