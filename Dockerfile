
FROM centos:centos7
MAINTAINER JR Bing <jr@jrbing.com>

VOLUME ["/rpmbuild"]
ADD ./scripts/build-rpm.sh /build-rpm.sh

RUN yum clean all && \
  yum -y update && \
  yum -y install epel-release && \
  yum -y install mock rpm-build redhat-rpm-config rpmdevtools nosync && \
  useradd -u 1000 builder && \
  usermod -a -G mock builder && \
  install --group=mock --mode=2775 --directory /rpmbuild/cache/mock && \
  echo "config_opts['cache_topdir'] = '/rpmbuild/cache/mock'" >> /etc/mock/site-defaults.cfg && \
  echo "config_opts['nosync'] = True" >> /etc/mock/site-defaults.cfg && \
  echo "config_opts['docker_unshare_warning'] = False" >> /etc/mock/site-defaults.cfg && \
  echo "config_opts['package_manager'] = 'yum'" >> /etc/mock/site-defaults.cfg && \
  chmod +x /build-rpm.sh

ADD ./etc/rpmmacros /home/builder/.rpmmacros
RUN chown builder:builder /home/builder/.rpmmacros

USER builder
ENV HOME /home/builder
CMD ["/build-rpm.sh"]
