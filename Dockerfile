FROM vbatts/slackware:14.2
#    echo "https://mirrors.slackware.com/slackware/slackware64-14.2/" > /etc/slackpkg/mirrors &&\
#    sed -i 's|\(WGETFLAGS=\).*|\1\"--passive-ftp --no-check-certificate\"|' /etc/slackpkg/slackpkg.conf &&\
#    echo "http://sunsite.icm.edu.pl/packages/linux-slackware/slackware64-14.2/" > /etc/slackpkg/mirrors &&\
#    echo "http://ftp.slackware.pl/pub/slackware/slackware64-14.2/" > /etc/slackpkg/mirrors &&\
ENV TERM xterm
RUN mv /etc/slackpkg/mirrors /etc/slackpkg/mirrors.org &&\
    echo "http://sunsite.icm.edu.pl/packages/linux-slackware/slackware64-14.2/" > /etc/slackpkg/mirrors &&\
    slackpkg -batch=on -default_answer=y update &&\
    slackpkg -batch=on -default_answer=y upgrade-all
#RUN slackpkg -batch=on -default_answer=y upgrade patches    
RUN slackpkg -batch=on -default_answer=y install \
            bash-completion \
            ca-certificates \
            dcron rsync libgcrypt pth libassuan libgpg-error gnupg2 curl lftp lzip\
            perl \
            python vim \
#            rpcbind libtirpc nfs-utils
            gamin cyrus-sasl gnutls p11-kit nettle libffi libidn\
            e2fsprogs openldap-client guile pkg-config acl
#            samba \
#            dbus cups cups-filters
RUN slackpkg -batch=on -default_answer=y install \
    binutils gcc-5 gcc-g++-5 \
  glibc-2 libmpc kernel-headers make autoconf automake m4 zlib bc \
  cmake libarchive nettle lzo libxml2 gc flex bison
RUN /usr/sbin/update-ca-certificates --fresh &&\
    cd /tmp &&\
    wget https://github.com/sbopkg/sbopkg/releases/download/0.38.1/sbopkg-0.38.1-noarch-1_wsr.tgz &&\
    installpkg /tmp/sbopkg-0.38.1-noarch-1_wsr.tgz &&\
    rm /tmp/sbopkg-0.38.1-noarch-1_wsr.tgz
RUN mkdir -p /var/lib/sbopkg/SBo/`cat /etc/slackware-version | awk -F' ' '{print $2}'` \
    /var/lib/sbopkg/queues /var/log/sbopkg /var/cache/sbopkg /tmp/SBo && \
    sbopkg -r && \
    sbopkg -B -i krb5 
RUN cd /root && \
    mkdir src && \
    cd src && \
    lftp -c mirror http://ftp.icm.edu.pl/pub/Linux/slackware/slackware64-current/source/n/bind && \
    lftp -c mirror http://ftp.icm.edu.pl/pub/Linux/slackware/slackware64-current/source/n/samba 
COPY bind.SlackBuild /root/src/bind



RUN cd /root/src/bind && \
    sh ./bind.SlackBuild && \
    installpkg /bind-*/bind-9.11.2-x86_64-1.txz &&\
    cd /root/src/samba && \
    sh ./samba.SlackBuild &&\
    installpkg /tmp/samba-4.7.4-x86_64-2.txz





#    sqg -a
#RUN cp /etc/samba/smb.conf-sample /etc/samba/smb.conf
#EXPOSE 631