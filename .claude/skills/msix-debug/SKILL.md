---
name: msix-debug
description: Use when the user wants to build, locally install, or debug the Windows MSIX package (komichi.msix) before Microsoft Store submission — e.g. "MSIXをテストしたい", "MSIXが灰色画面になる", "Store提出前に確認したい", "Add-AppxPackageが失敗する".
---

# MSIX ローカルデバッグ手順

## 前提知識: なぜ`store: true`のままだと絶対にインストールできないか

`pubspec.yaml`の`msix_config`が`store: true`のとき、`msix`パッケージ（v3.18.0時点、`lib/msix.dart`の`_buildMsixFiles`/`_packMsixFiles`)は

```dart
if (_config.signMsix && !_config.store) { ... }
```

という条件で**署名処理そのものを丸ごとスキップする**。これはバグではなく仕様：Store提出用パッケージは未署名のままアップロードし、Microsoft側の認証パイプラインが審査時に正式署名する前提になっている。

そのため `store: true` でビルドした `.msix` を `Add-AppxPackage` でインストールすると、必ず

```
エラー 0x800B0100: アプリ パッケージは、署名の検証用にデジタル署名されている必要があります。
```

になる。`install_certificate`をtrueにしても無意味（同じ条件式でガードされているため呼ばれない）。**ローカルでインストール確認をしたいなら、一時的に`store: false`にする以外に方法はない。**

## ローカルテスト手順

1. `pubspec.yaml`の`msix_config`を一時的に変更する:
   ```yaml
   store: false
   install_certificate: false   # 対話プロンプトが絡むので使わない。下記の手動手順を使う
   certificate_path: C:\dev\komichi_test.pfx
   certificate_password: '1234'
   ```

2. 公開者情報（`publisher`の値）と一致するSubjectで自己署名証明書を作成し、pfxとして書き出す（管理者権限不要、ここまではCurrentUserスコープで完結する）:
   ```powershell
   $cert = New-SelfSignedCertificate -Type Custom -Subject "CN=05798F0E-41EC-4FF9-BBAB-61384063660A" `
     -KeyUsage DigitalSignature -FriendlyName "komichi test cert" `
     -CertStoreLocation "Cert:\CurrentUser\My" `
     -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")
   $pwd = ConvertTo-SecureString -String "1234" -Force -AsPlainText
   Export-PfxCertificate -Cert "Cert:\CurrentUser\My\$($cert.Thumbprint)" -FilePath "C:\dev\komichi_test.pfx" -Password $pwd
   ```
   Subjectの`CN=...`は`pubspec.yaml`の`msix_config.publisher`と完全一致させること。ずれていると署名はできても`Add-AppxPackage`が別のエラーで弾く。

3. ビルド＆署名:
   ```powershell
   dart run msix:create
   ```

4. **重要**: `Add-AppxPackage`によるインストール検証は`LocalMachine`スコープの証明書ストアしか見ない。`CurrentUser\Root`や`CurrentUser\TrustedPeople`にいくら証明書を入れても`0x800B0109`（ルート証明書が信頼されていない）で失敗し続ける。`LocalMachine\Root`への書き込みには本物の管理者権限が要る。

   **これは自動化できない**。UAC同意はGUIダイアログであり、非対話シェル（CI・自動化ツール）からは絶対に完了させられない（`-Verb runAs`をスクリプトから呼んでも同様にブロックされる）。ユーザー自身が「管理者としてPowerShellを実行」してから、以下を手動で叩く必要がある:
   ```powershell
   $pwd = ConvertTo-SecureString -String "1234" -Force -AsPlainText
   Import-PfxCertificate -FilePath "C:\dev\komichi_test.pfx" -CertStoreLocation Cert:\LocalMachine\Root -Password $pwd
   Add-AppxPackage -Path build\windows\x64\runner\Release\komichi.msix
   ```

5. インストールされたアプリはスタートメニューから起動する（タスクバーには自動で出ない）。

6. **確認が終わったら`pubspec.yaml`を必ず元に戻す**（`store: true` / `install_certificate: false`、`certificate_path`・`certificate_password`は削除）。`store: false`のままStore提出すると審査に通らない。

## 本当にMSIX版が起動しているか確認する方法

素のexeと紛らわしいので、以下で実際にインストールされているパッケージを確認できる:

```powershell
Get-AppxPackage -Name "*komichi*" | Format-List Name, PackageFullName, InstallLocation, Version, SignatureKind
```

- `InstallLocation`が`C:\Program Files\WindowsApps\...`配下 → MSIXパッケージの証拠（素のexeはここに置けない）
- `SignatureKind: Developer` → 自己署名証明書で正しく署名されている証拠（`None`なら未署名）

## デバッグ時の重要な注意: release/MSIXビルドはエラー画面を出さない

Flutterの赤いエラー画面（`FlutterError`のデバッグ表示）は**デバッグビルド専用機能**で、`--release`ビルド（MSIXは常にこれ）では完全に無効化される。初期化中に例外が起きても、エラーダイアログも赤画面も出さず、**ただ何も描画されない灰色の空白ウィンドウになるだけ**。

「灰色ウィンドウで何も映らない、エラーも出ない」を見たら、まずアイコンキャッシュ等の見た目の問題ではなく、**起動シーケンス中の未捕捉例外**を疑うこと。デバッグには:
- 一旦`flutter run -d windows`（デバッグモード）で同じコードパスを踏んで赤画面を出させ、根本原因を特定する
- それができない場合はコンソールから直接exeを実行し、`print`/`debugPrint`の標準出力を確認する
