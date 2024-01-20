# Node.jsのイメージをベースとして使用
FROM node:14.17.6 as node

# Rubyのイメージをベースとして使用
FROM ruby:3.0.2

# Node.jsイメージから必要なファイルをコピー
COPY --from=node /opt/yarn-* /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
&& ln -fs /usr/local/lib/node_modules/npm/bin/npx /usr/local/bin/npx \
&& ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn \
&& ln -fs /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

# 必要なパッケージをインストール
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# アプリケーションディレクトリを作成
RUN mkdir /myapp
WORKDIR /myapp

# GemfileとGemfile.lockをコピーしてbundle installを実行
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install

# アプリケーションのコードをコピー
COPY . /myapp

# エントリーポイントスクリプトをコピーして実行権限を付与
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# ポート3000を公開
EXPOSE 3000

# Railsサーバーを起動
CMD ["rails", "server", "-b", "0.0.0.0"]
