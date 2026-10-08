#!/usr/bin/env bash
set -euo pipefail

repo="madiks/gogo-releases"
base_url="https://github.com/$repo/releases"
requested_version="${GOGO_VERSION:-}"
install_dir="${XDG_BIN_HOME:-$HOME/.local/bin}"
archive=""
work_dir=""
staged_binary=""

fail() {
  printf 'gogo install: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [[ -n "$staged_binary" ]]; then
    rm -f -- "$staged_binary"
  fi
  if [[ -n "$work_dir" ]]; then
    rm -rf -- "$work_dir"
  fi
}
trap cleanup EXIT

for command in curl tar mktemp install mv; do
  command -v "$command" >/dev/null 2>&1 || fail "缺少必需命令：$command"
done

case "$(uname -s)" in
  Darwin) os="darwin" ;;
  Linux) os="linux" ;;
  *) fail "不支持的操作系统：$(uname -s)" ;;
esac

case "$(uname -m)" in
  arm64|aarch64) arch="arm64" ;;
  x86_64|amd64) arch="amd64" ;;
  *) fail "不支持的 CPU 架构：$(uname -m)" ;;
esac

if [[ -n "$requested_version" ]]; then
  version="$requested_version"
else
  resolved_url="$(curl -fsSL -o /dev/null -w '%{url_effective}' "$base_url/latest")" || fail "无法获取最新正式版本"
  version="${resolved_url##*/}"
fi

version_pattern='^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z]+([.-][0-9A-Za-z]+)*)?$'
[[ "$version" =~ $version_pattern ]] || fail "无效的版本：$version"

archive="gogo_${version}_${os}_${arch}.tar.gz"
release_url="$base_url/download/$version"
work_dir="$(mktemp -d)" || fail "无法创建临时目录"
chmod 700 "$work_dir"

printf '下载 GoGo %s (%s/%s)...\n' "$version" "$os" "$arch"
curl -fsSL --retry 2 -o "$work_dir/$archive" "$release_url/$archive" || fail "二进制下载失败"
curl -fsSL --retry 2 -o "$work_dir/checksums.txt" "$release_url/checksums.txt" || fail "校验文件下载失败"

expected="$(awk -v name="$archive" '$2 == name { print $1 }' "$work_dir/checksums.txt")"
[[ "$expected" =~ ^[0-9a-fA-F]{64}$ ]] || fail "校验文件中缺少唯一、有效的 $archive SHA256"
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$work_dir/$archive")"
else
  command -v shasum >/dev/null 2>&1 || fail "缺少 SHA256 校验工具"
  actual="$(shasum -a 256 "$work_dir/$archive")"
fi
[[ "${actual%% *}" == "$expected" ]] || fail "SHA256 校验失败"

contents="$(tar -tzf "$work_dir/$archive")" || fail "无法读取压缩包"
[[ "$contents" == "gogo" ]] || fail "压缩包内容不符合预期"
tar -xzf "$work_dir/$archive" -C "$work_dir" || fail "解压失败"
[[ -f "$work_dir/gogo" && ! -L "$work_dir/gogo" ]] || fail "压缩包中缺少有效二进制"
chmod 700 "$work_dir/gogo"
reported="$("$work_dir/gogo" -version)" || fail "新版本无法运行"
[[ "$reported" == "gogo $version" ]] || fail "二进制版本与 Release 不一致：$reported"

if [[ -x "$install_dir/gogo" ]]; then
  current="$("$install_dir/gogo" -version 2>/dev/null || true)"
  if [[ "$current" == "$reported" ]]; then
    printf 'GoGo %s 已安装：%s\n' "$version" "$install_dir/gogo"
    exit 0
  fi
fi

mkdir -p "$install_dir" || fail "无法创建安装目录：$install_dir"
staged_binary="$(mktemp "$install_dir/.gogo.XXXXXX")" || fail "无法准备安装文件"
install -m 755 "$work_dir/gogo" "$staged_binary" || fail "无法复制二进制"
mv -f "$staged_binary" "$install_dir/gogo" || fail "无法安装到 $install_dir/gogo"
staged_binary=""

printf 'GoGo %s 已安装：%s\n' "$version" "$install_dir/gogo"
case ":$PATH:" in
  *":$install_dir:"*) ;;
  *) printf '请将 %s 加入 PATH，然后运行 gogo -version。\n' "$install_dir" ;;
esac
