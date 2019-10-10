FROM archlinux/base AS build-package
RUN pacman -Syu --needed --noconfirm    # Avoid some issues with packages. E.g. updates on dependencies from pacman itself
RUN pacman -Sy --needed --noconfirm base-devel git curl sudo

# Add a user to use in the docker container
RUN groupadd -g 42 awesome && useradd -r -u 42 --create-home -g awesome awesome

# Give user root access via sudo
RUN echo "awesome ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Do some system setup as the root user
RUN mkdir /.cache && sudo chown awesome:awesome /.cache/
RUN echo 'EDITOR=false' > /etc/profile.d/editor.sh && chmod +x /etc/profile.d/editor.sh
RUN echo 'EDITOR=false' >> /etc/bash.bashrc

# Set default makepkg configuration
COPY makepkg.conf /etc/makepkg.conf

# Become the user
USER awesome

# Install yay AUR helper
RUN mkdir -p /tmp/yay && cd /tmp/yay && . /etc/profile.d/perlbin.sh && curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay-bin && makepkg PKGBUILD --skippgpcheck --needed --noconfirm


FROM archlinux/base
COPY --from=build-package /etc/profile.d/editor.sh /etc/profile.d/
COPY --from=build-package /etc/bash.bashrc /etc/
COPY --from=build-package /etc/makepkg.conf /etc/
RUN pacman -Syu --needed --noconfirm && pacman -Scc --noconfirm && rm -rf /var/lib/pacman/sync/*
RUN pacman -Syu --needed --noconfirm git sudo && pacman -Scc --noconfirm && rm -rf /var/lib/pacman/sync/*

COPY --from=build-package /tmp/yay/*.tar.xz /tmp
RUN pushd tmp && pacman --noconfirm -U *.tar.xz

RUN yay -S --needed --noconfirm --editor false --answerclean None --answeredit None --answerupgrade None --answerdiff None --save

# Enable building as the nobody user
RUN usermod -e 2100-01-01 -- nobody
RUN echo "nobody ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir --mode=777 /.config
RUN mkdir --mode=777 /.cache
