---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: GitLab Helmチャート
---

{{< details >}}

- プラン: Free、Premium、Ultimate
- 提供形態: GitLab Self-Managed

{{< /details >}}

クラウドネイティブバージョンのGitLabをインストールするには、GitLab Helmチャートを使用します。このチャートには、開始するのに必要なすべてのコンポーネントが含まれており、大規模なデプロイに併せたスケーリングも可能です。

OpenShiftベースのインストールでは、[GitLab Operator](https://docs.gitlab.com/operator/)を使用します。それ以外の場合は、[セキュリティコンテキストの制約](https://docs.gitlab.com/operator/security_context_constraints.html)をご自身で更新する必要があります。

{{< alert type="warning" >}}

デフォルトのHelmチャート設定は、**本番環境を対象としたものではありません**。デフォルト値では、_すべての_GitLabサービスがクラスターにデプロイされる実装が作成されますが、これは**本番環境のワークロードには適していません**。本番環境へのデプロイでは、[クラウドネイティブハイブリッドリファレンスアーキテクチャ](installation/_index.md#use-the-reference-architectures)に従う**必要があります**。

{{< /alert >}}

本番環境へのデプロイでは、Kubernetesに関する確かな実務知識が必要です。このデプロイ方法では、管理、可観測性、概念が従来のデプロイとは異なります。

GitLab Helmチャートは複数の[サブチャート](charts/gitlab/_index.md)で構成されており、それぞれ個別にインストールできます。

## 詳しく見る {#learn-more}

- [GKEまたはEKSでGitLabチャートをテストする](quickstart/_index.md)
- [LinuxパッケージからGitLabチャートに移行する](installation/migration/_index.md)
- [デプロイの準備](installation/_index.md)
- [デプロイ](installation/deployment.md)
- [デプロイのオプションを表示する](installation/command-line-options.md)
- [グローバルを設定する](charts/globals.md)
- [サブチャートを表示する](charts/gitlab/_index.md)
- [高度な設定オプションを表示する](advanced/_index.md)
- [アーキテクチャに関する決定事項を表示する](architecture/_index.md)
- 開発にコントリビュートする（[デベロッパー向けドキュメント](development/_index.md)と[コントリビュートガイドライン](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/CONTRIBUTING.md)を参照）
- [イシュー](https://gitlab.com/gitlab-org/charts/gitlab/-/issues)を作成する
- [マージリクエスト](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests)を作成する
- [トラブルシューティング](troubleshooting/_index.md)情報を表示する
