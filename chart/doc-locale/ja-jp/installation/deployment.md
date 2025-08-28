---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: GitLab Helmチャートのデプロイ
---

{{< details >}}

- プラン: Free、Premium、Ultimate
- 提供形態: GitLab Self-Managed

{{< /details >}}

`helm install`を実行する前に、GitLabの実行方法についていくつかの決定をしておく必要があります。オプションは、Helmの`--set option.name=value`コマンドラインオプションを使用して指定できます。このガイドでは、必要な値と一般的なオプションについて説明します。オプションの完全なリストについては、[インストールコマンドラインオプション](command-line-options.md)をお読みください。

{{< alert type="warning" >}}

デフォルトのHelmチャート設定は、**本番環境を対象としたものではありません**。デフォルトのチャートで作成されるのは概念実証（PoC）の実装であり、そこではすべてのGitLabサービスがクラスターにデプロイされます。本番環境にデプロイする場合は、[クラウドネイティブハイブリッドリファレンスアーキテクチャ](_index.md#use-the-reference-architectures)に従う必要があります。

{{< /alert >}}

本番環境へのデプロイでは、Kubernetesに関する確かな実務知識が必要です。このデプロイ方法では、管理、可観測性、概念が従来のデプロイとは異なります。

## Helmを使用してデプロイする {#deploy-using-helm}

設定オプションをすべて収集したら、依存関係を取得してHelmを実行することができます。この例では、Helmリリースを`gitlab`という名前にしてあります。

```shell
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.hosts.domain=example.com \
  --set global.hosts.externalIP=10.10.10.10 \
  --set certmanager-issuer.email=me@example.com
```

以下の点に注意してください。

- Helmコマンドは、すべてHelm v3構文を使用して指定します。
- `--generate-name`オプションを使用するのでない限り、Helm v3では、コマンドラインの位置引数としてリリース名を指定する必要があります。
- Helm v3では、値に単位を付加して期間を指定する必要があります（例: `120s` = `2m`、`210s` = `3m30s`）。`--timeout`オプションは、単位の指定_なし_で秒数として処理されます。
- `--timeout`オプションの使用には、紛らわしい面があります。`--timeout`が適用されるHelmのインストールまたはアップグレード中にデプロイされるコンポーネントは複数あるからです。`--timeout`の値は、全コンポーネントのインストールの全体に適用されるのではなく、各コンポーネントのインストールに個別に適用されます。3分後にHelmインストールを中断しようと考えて`--timeout=3m`を使っても、インストールされるどのコンポーネントもそれぞれが3分以内にインストールされてしまい、結果としてインストール完了が5分後になる可能性があります。

`--version <installation version>`オプションを使用することにより、GitLabの特定のバージョンをインストールすることもできます。

チャートのバージョンとGitLabのバージョンの間のマッピングについては、[GitLabバージョンのマッピング](version_mappings.md)をご覧ください。

タグの付いたリリースではなく開発ブランチをインストールする手順については、[デベロッパー向けデプロイのドキュメント](../development/deploy.md)をご覧ください。

## GitLab Helmチャートの整合性と起源を検証する {#verifying-the-integrity-and-origin-of-gitlab-helm-charts}

[Helm Provenance](https://helm.sh/docs/topics/provenance/)を使用することにより、GitLab Helmチャートの整合性と起源を検証できます。詳しくは、[GitLab Helmチャートの由来](chart-provenance.md)をご覧ください。

## デプロイをモニタリングする {#monitoring-the-deployment}

これにより、デプロイ完了時に、インストールされたリソースのリストが出力されます。完了には5〜10分かかる場合があります。

デプロイの状態は、`helm status gitlab`を実行することにより確認できます。別のターミナルでコマンドを実行することにより、デプロイ実行中に確認することもできます。

## 最初のログイン {#initial-login}

GitLabインスタンスには、インストール時に指定されたドメインにアクセスすることによってアクセスできます。[グローバルホスト設定](../charts/globals.md#configure-host-settings)が変更されていない限り、デフォルトのドメインは`gitlab.example.com`になります。初期ルートパスワードのシークレットを手動で作成した場合は、それを使用して`root`ユーザーとしてサインインできます。そうでない場合、`root`ユーザー用のランダムなパスワードがGitLabによって自動作成されます。これは、次のコマンドによって抽出できます（上記のコマンドを使用した場合は`<name>`をリリース名`gitlab`に置き換えます）。

```shell
kubectl get secret <name>-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
```

## GitLab Community Edition（CE）をデプロイする {#deploy-the-community-edition}

デフォルトの場合、HelmチャートではGitLab Enterprise Edition（EE）を使用します。GitLab Enterprise Edition（EE）はGitLabの無料オープンコアバージョンであり、オプションとして追加機能を利用するには有料プランにアップグレードする必要があります。必要に応じて、代わりにMIT Expatライセンスの下でライセンスされているGitLab Community Edition（CE）を使用することもできます。[2つのエディションの違い](https://about.gitlab.com/install/ce-or-ee/)の詳細については、こちらをご覧ください。

*GitLab Community Edition（CE）をデプロイするには、Helmインストールコマンドに次のオプションを含めます。*

```shell
--set global.edition=ce
```

## GitLab Community Edition（CE）をGitLab Enterprise Edition（EE）に変換する {#convert-community-edition-to-enterprise-edition}

[GitLab Community Edition（CE）をデプロイした](#deploy-the-community-edition)後、GitLab Enterprise Edition（EE）に変換する場合は、`--set global.edition=ce`を指定せずにGitLabを再デプロイする必要があります。個々のイメージ（`--set gitlab.unicorn.image.repository=registry.gitlab.com/gitlab-org/build/cng/gitlab-unicorn-ce`など）も指定した場合は、それらのイメージの指定をすべて除去する必要があります。

デプロイ後、[GitLab Enterprise Edition（EE）のライセンスをアクティブにする](https://docs.gitlab.com/administration/license/)ことができます。

## 推奨される次のステップ {#recommended-next-steps}

インストールが完了したら、[推奨される次のステップ](https://docs.gitlab.com/install/next_steps/)（認証オプションやサインアップ制限など）を実行することを検討してください。
