FROM jupyter/base-notebook
ARG passwd
USER root
# vim related staffs
## install vim
RUN rm -rf /usr/local/share/vim /usr/bin/vim \
    && apt-get clean \
    && apt-get update \
    && apt-get -y install liblua5.1-dev luajit libluajit-5.1 git  python3-dev ruby-dev ruby2.5 ruby2.5-dev libperl-dev libncurses5-dev libatk1.0-dev libx11-dev libxpm-dev libxt-dev \
    && cd ~ \
    && git clone https://github.com/vim/vim \
    && cd vim \
    && make distclean \
    && ./configure \
        --enable-multibyte \
        --enable-perlinterp=dynamic \
        --enable-rubyinterp=dynamic \
        --with-ruby-command=/usr/bin/ruby \
        --enable-python3interp=yes \
        --with-python3-command=/usr/bin/python3 \
        --with-python3-config-dir=/usr/bin/python3 \
        --enable-luainterp \
        --with-luajit \
        --enable-cscope \
        --enable-gui=auto \
        --with-features=huge \
        --with-x \
        --enable-fontset \
        --enable-largefile \
        --disable-netbeans \
        --with-compiledby="ERICK ROCHA <contato@erickpatrick.net>" \
        --enable-fail-if-missing \
    && make && make install \
    && cd .. && rm -rf vim

## install spf13
ADD ./.spf13-vim-3 /home/$NB_USER/.spf13-vim-3
RUN cd /home/$NB_USER && bash .spf13-vim-3/bootstrap.sh

## install tabnine
RUN git clone --depth 1 https://github.com/zxqfl/tabnine-vim /home/$NB_USER/tabnine-vim \
    && echo 'set rtp+=/home/$NB_USER/tabnine-vim' >> /home/$NB_USER/.vimrc


# go related staffs
# install go
RUN wget https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz \
    && tar -xvf go1.12.7.linux-amd64.tar.gz \
    && mv go /usr/local \
    && rm -rf go1.12.7.linux-amd64.tar.gz

ENV GOROOT=/usr/local/go \
    GOPATH=/home/$NB_USER/go \
    PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# install gzh
RUN wget https://github.com/bojand/ghz/releases/download/v0.41.0/ghz_0.41.0_Linux_x86_64.tar.gz \
    && mkdir -p ghz-bin \
    && tar -zvxf ghz_0.41.0_Linux_x86_64.tar.gz -C ghz-bin \
    && mkdir -p /home/$NB_USER/go/bin \
    && mv ghz-bin/* /home/$NB_USER/go/bin/ \
    && rm -rf ghz-bin ghz_0.41.0_Linux_x86_64.tar.gz


# python related staff
RUN pip install jupyter_core==4.5.0 \
                notebook==5.7.8 \
                awscli \
                jupyter_contrib_nbextensions \
    && jupyter contrib nbextension install --sys-prefix

# shell related staffs
## install zsh
RUN apt-get clean \
    && apt-get update \
    && apt-get -y install zsh \
    && apt-get -y install powerline fonts-powerline \
    && git clone https://github.com/robbyrussell/oh-my-zsh.git /home/$NB_USER/.oh-my-zsh \
    && cp /home/$NB_USER/.oh-my-zsh/templates/zshrc.zsh-template /home/$NB_USER/.zshrc \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$NB_USER/.zsh-syntax-highlighting --depth 1 \
    && echo 'source /home/$NB_USER/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> /home/$NB_USER/.zshrc
ADD ./bootstrap /usr/local/bin/bootstrap
RUN chmod 755 /usr/local/bin/bootstrap
RUN echo "jovyan ALL=(ALL)     ALL" >> /etc/sudoers.d/jovyan \
    && echo "jovyan:$passwd" | chpasswd
RUN sed -i '/jovyan/s/:\/bin\/bash/:\/bin\/zsh/g' /etc/passwd \
    && sudo sed -i '/set -e/ a \\nbootstrap' /usr/local/bin/start-notebook.sh
ADD ./terminal-js/main.min.js /opt/conda/lib/python3.7/site-packages/notebook/static/terminal/js/main.min.js
RUN chown -R jovyan:users /home/jovyan
USER $NB_UID
