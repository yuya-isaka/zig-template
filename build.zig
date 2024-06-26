const std = @import("std");

// 関数は命令的に見えるかもしれませんが、その役割は外部ランナーによって実行されるビルドグラフを宣言的に構築することです。
pub fn build(b: *std.Build) void {
    // 標準的なターゲットオプションは、`zig build`を実行する人がビルド対象を選択できるようにします。
    // 今回は、デフォルトを上書きしていません。（デフォルトはネイティブ）
    // 任意のターゲットが許可されます。
    // サポートされるターゲットセットを制限する他のオプションも利用可能です。
    const target = b.standardTargetOptions(.{});

    // 標準の最適化オプションは、`zig build`を実行する人がデバッグ、リリースセーフ、リリースファスト、リリーススモールの間で選択できるようにします。
    // 現在、優先リリースモードを設定していません。ユーザーに最適化方法を決定させます。
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig-template",
        // 現在、メインソースファイルは単なるパスですが、より複雑なビルドスクリプトでは、これは生成されたファイルになる可能性があります。
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // ユーザーが「インストール」ステップを呼び出す際に実行可能ファイルを標準の場所にインストールする意図を宣言します（`zig build`を実行したときのデフォルトステップです）。
    // Zigで言う「標準の場所」とは、zig buildを使用してビルドされるアプリケーションのインストール先を指します。
    // この「標準の場所」は、通常、Zigのビルドシステムが自動的に設定するパスです。
    // 具体的には、この場所はプラットフォームやユーザーの設定に依存しますが、多くの場合、以下のようなデフォルトのパスになります：
    //    - LinuxまたはUnix系: /usr/local/bin や /usr/bin などのシステム全体のバイナリディレクトリにインストールされることが一般的です。
    //    - Windows: よくC:\Program Files\やユーザーのディレクトリ内の適切な場所にインストールされます。
    b.installArtifact(exe);

    // ----------------------------------------------------------------------------------------------------------------------------------------

    // ビルドグラフに実行ステップを作成します。
    // Zigのビルドシステムでは、「ビルドグラフ」という概念があります。
    // これは、プロジェクトのビルドプロセスを構成するさまざまなタスク（ステップ）とそれらの依存関係を表したグラフのことです。各ステップは特定のビルド操作を表し、例えばコンパイル、リンク、テスト実行などが含まれます
    // 他のステップがそれに依存して評価されるときに実行されます。
    // 以下の行はそのような依存関係を設定します。
    const run_cmd = b.addRunArtifact(exe);

    // 実行ステップをインストールステップに依存させることにより、キャッシュディレクトリ内から直接実行するのではなく、インストールディレクトリから実行されます。
    // 必須ではありませんが、アプリケーションが他のインストールされたファイルに依存している場合、これによりそれらが存在し、期待された場所にあることが保証されます。
    run_cmd.step.dependOn(b.getInstallStep());

    // ユーザーはビルドコマンド自体でアプリケーションに引数を渡すことができます。
    // 例えばこのように：`zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // ビルドステップが作成されます。
    // `zig build --help`メニューに表示され、次のように選択できます：`zig build run`
    // デフォルトの「インストール」ではなく、「実行」ステップを評価します。
    const run_step = b.step("run", "アプリを実行");
    run_step.dependOn(&run_cmd.step);

    // ----------------------------------------------------------------------------------------------------------------------------------------

    // ユニットテストのためのステップを作成します。
    // テスト実行可能ファイルをビルドしますが、実行はしません。
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // 以前に実行ステップを作成したのと同様に、これは`zig build --help`メニューに「テスト」というステップを公開し、ユーザーにユニットテストの実行を要求する方法を提供します。
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
