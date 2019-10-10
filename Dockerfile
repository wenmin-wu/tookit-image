FROM python:3.7.4

# install vim
RUN rm -rf /usr/local/share/vim /usr/bin/vim \
    && apt-get update \
    && apt-get -y install liblua5.1-dev luajit libluajit-5.1 python-dev python3-dev ruby-dev ruby2.5 ruby2.5-dev libperl-dev libncurses5-dev libatk1.0-dev libx11-dev libxpm-dev libxt-dev \
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

ENV HOME /root

# install spf13
ADD ./.spf13-vim-3 $HOME/.spf13-vim-3
RUN cd $HOME && bash .spf13-vim-3/bootstrap.sh

# install tabnine
RUN git clone --depth 1 https://github.com/zxqfl/tabnine-vim $HOME/tabnine-vim \
    && echo 'set rtp+=${HOME}/tabnine-vim' >> $HOME/.vimrc

# install go
RUN wget https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz \
    && tar -xvf go1.12.7.linux-amd64.tar.gz \
    && mv go /usr/local \
    && rm -rf go1.12.7.linux-amd64.tar.gz
ENV GOROOT /usr/local/go
ENV GOPATH $HOME/go

# install gzh
RUN wget https://github.com/bojand/ghz/releases/download/v0.41.0/ghz_0.41.0_Linux_x86_64.tar.gz \
    && mkdir -p ghz-bin \
    && tar -zvxf ghz_0.41.0_Linux_x86_64.tar.gz -C ghz-bin \
    && mkdir -p $HOME/go/bin \
    && mv ghz-bin/* $HOME/go/bin/ \
    && rm -rf ghz-bin ghz_0.41.0_Linux_x86_64.tar.gz

ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH

# install awscli
RUN pip3 install awscli --upgrade

# install zsh
RUN apt-get -y install zsh \
    && apt-get -y install powerline fonts-powerline \
    && git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh-syntax-highlighting --depth 1 \
    && echo 'source ${HOME}/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> $HOME/.zshrc \
    && echo "if [ -e ~/.bashrc ]; then\n    source ~/.bashrc\nfi" >> $HOME/.zshrc

ADD ./bootstrap.sh /bootstrap.sh
RUN chmod 755 ./bootstrap.sh
ENTRYPOINT ["/bin/zsh"]
