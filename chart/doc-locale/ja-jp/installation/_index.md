---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Helmを使用して
---

{{< details >}}

- プラン: Free、Premium、Ultimate
- 提供形態: GitLab Self-Managed

{{< /details >}}

クラウドネイティブの

すでに[前提要件](tools.md)がインストールされ、設定されていることを前提に、`helm`コマンドで[GitLabをデプロイ](deployment.md)できます。

{{< alert type="warning" >}}

デフォルトのHelmチャート設定は、**本番環境を対象としたものではありません**。デフォルトのチャートで作成されるのは概念実証（PoC）の実装であり、そこではすべてのGitLabサービスがクラスターにデプロイされます。本番環境にデプロイする場合は、[クラウドネイティブハイブリッドリファレンスアーキテクチャ](#use-the-reference-architectures)に従う必要があります。

{{< /alert >}}

本番環境へのデプロイでは、Kubernetesに関する確かな実務知識が必要です。このデプロイ方法では、管理、可観測性、概念が従来のデプロイとは異なります。

本番環境へのデプロイ:

- PostgreSQL、Redis、Gitaly（Gitリポジトリのストレージデータプレーン）などのステートフルコンポーネントは、PaaSまたはコンピューティングインスタンス上のクラスターの外部で実行する必要があります。この設定は、GitLab本番環境にあるさまざまなワークロードをスケールしたり、信頼性の高い仕方でサービスを提供したりするために必要です。
- PostgreSQL、Redis、Gitリポジトリストレージ以外のすべてのストレージのオブジェクトストレージには、Cloud PaaSを使用する必要があります。

お使いのGitLabインスタンスでKubernetesが不要な場合は、より簡単な代替手段として、[リファレンスアーキテクチャ](https://docs.gitlab.com/administration/reference_architectures/)を参照してください。

## コンテナイメージ {#container-images}

GitLab Helmチャートは、[クラウドネイティブGitLab（CNG）](https://gitlab.com/gitlab-org/build/CNG)コンテナイメージを使用してGitLabをデプロイします。CNGイメージに加えて、デフォルト設定ではサードパーティのイメージを使用して、PostgreSQL、Redis、MinIOをデプロイします。

上記のとおり、本番環境インスタンスでは、これらの（ステートフルな）サードパーティサービスをGitLabチャートとともにデプロイしないでください。

外部サービスを使用するようにチャートを設定する方法については、次のドキュメントを参照してください。

1. [外部データベース](../advanced/external-db/_index.md)
1. [外部Redis](../advanced/external-redis/_index.md)
1. [外部オブジェクトストレージ](../advanced/external-object-storage/_index.md)

{{< alert type="note" >}}

2024年12月から、[Bitnamiはビルドポリシーを変更](https://github.com/bitnami/containers/issues/75671)し、無料カタログ内の各アプリケーションについて最新の安定したメジャーバージョンのみを更新するようになりました。GitLabチャートは引き続き、一般公開されているイメージをデフォルトで使用します。

{{< /alert >}}

## 外部ステートフルデータを使用するようにHelmチャートを設定する {#configure-the-helm-chart-to-use-external-stateful-data}

PostgreSQL、Redis、Gitリポジトリストレージ以外のすべてのストレージ、およびGitリポジトリストレージ（Gitaly）などの項目のために、外部ステートフルストレージを参照するよう、GitLab Helmチャートを設定することができます。

本番環境インスタンスでは、上記の通り、これらの（ステートフルな）サードパーティサービスをGitLabチャートとともにDeployしないでください。

本番環境グレードの実装では、適切なチャートパラメータを使用することにより、選択した[リファレンスアーキテクチャ](https://docs.gitlab.com/administration/reference_architectures/)に合わせて事前構築された外部ステートストアを参照する必要があります。

### リファレンスアーキテクチャを使用する {#use-the-reference-architectures}

KubernetesにGitLabインスタンスをデプロイするためのリファレンスアーキテクチャが特に[クラウドネイティブハイブリッド](https://docs.gitlab.com/administration/reference_architectures/#cloud-native-hybrid)と呼ばれるのは、本番環境グレードの実装の場合、すべてのGitLabサービスをクラスター内で実行できるわけではないためです。ステートフルGitLabコンポーネントは、すべて、Kubernetesクラスターの外部にデプロイする必要があります。

使用可能なクラウドネイティブハイブリッドリファレンスアーキテクチャのサイズのリストについては、[リファレンスアーキテクチャ](https://docs.gitlab.com/administration/reference_architectures/#cloud-native-hybrid)のページをご覧ください。たとえば、こちらの[クラウドネイティブハイブリッドリファレンスアーキテクチャ](https://docs.gitlab.com/administration/reference_architectures/3k_users/#cloud-native-hybrid-reference-architecture-with-helm-charts-alternative)に、ユーザー数3,000のケースが紹介されています。

### Infrastructure as Code（IaC）とビルダーリソースを使用する {#use-infrastructure-as-code-iac-and-builder-resources}

GitLabでは、Helmチャートと補足的なクラウドインフラストラクチャの組み合わせを設定できるInfrastructure as Codeを開発しています。

- [GitLab Environment Toolkit IaC](https://gitlab.com/gitlab-org/gitlab-environment-toolkit)。
- [実装パターン: AWS EKSでクラウドネイティブハイブリッドGitLabをプロビジョニングする](https://docs.gitlab.com/solutions/cloud/aws/gitlab_instance_on_aws/): このリソースは、GitLab Performance Toolkitでテスト済みの部品表を提供し、予算編成にAWS料金計算ツールを使用しています。
