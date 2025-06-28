FROM archlinux:latest

# install basics + X11 auth utility
RUN pacman -Sy --needed --noconfirm \
      base-devel \
      git \
      sudo \
      zsh \
      xorg-xauth \
      nvim \
      stow \
      starship \
      eza \
      zoxide \
      fzf \
    && pacman -Scc --noconfirm

# create non-root user
RUN useradd -m -G wheel dev \
    && echo "dev ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER dev
WORKDIR /home/dev
SHELL ["/usr/bin/zsh", "-lc"]

# carry DISPLAY env into the image (optional default)
ENV DISPLAY=:0

CMD ["zsh"]

