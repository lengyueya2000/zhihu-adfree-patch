"""Patch Zhiliao module: replace its hardcoded Zhihu-official-cert SHA1
whitelist constant with the SHA1 of the certificate that actually signs
the patched APK, then fix the dex checksum/SHA1 header fields.

Zhiliao's MainHook compares the running app's signing cert SHA1 against a
built-in 20-byte constant (the official Zhihu cert). Under LSPatch the app
is re-signed, so without this patch every hook is silently skipped.

Usage: python patch_zhiliao.py <zhiliao_original.apk> <zhiliao_patched.apk> <signing_cert.pem>
"""
import sys, zipfile, hashlib, struct, zlib, subprocess, tempfile, base64, os

def cert_sha1(keystore, cert_pem=None):
    if cert_pem:
        pem = open(cert_pem, 'rb').read()
    else:
        raise SystemExit('need cert pem')
    b64 = b''.join(l for l in pem.splitlines() if not l.startswith(b'---'))
    der = base64.b64decode(b64)
    return hashlib.sha1(der).digest()

def main():
    src_apk, dst_apk, cert_pem = sys.argv[1], sys.argv[2], sys.argv[3]
    new_sha1 = cert_sha1(None, cert_pem)
    print('signing cert SHA1:', new_sha1.hex())

    tmp_dex = tempfile.mktemp(suffix='.dex')
    with zipfile.ZipFile(src_apk) as z:
        dex = z.read('classes.dex')

    # official Zhihu cert SHA1 hardcoded by Zhiliao
    old = bytes.fromhex('b6f997e3827be11af2fa4a153fea3fe627686602')
    cnt = dex.count(old)
    if cnt != 1:
        print(f'WARN: expected 1 occurrence of whitelist SHA1, found {cnt}; aborting')
        sys.exit(1)
    dex = dex.replace(old, new_sha1)

    # fix dex header: SHA1 (offset 12, over bytes from 32) then adler32 (offset 8, over bytes from 12)
    dex = bytearray(dex)
    dex[12:32] = hashlib.sha1(bytes(dex[32:])).digest()
    struct.pack_into('<I', dex, 8, zlib.adler32(bytes(dex[12:])) & 0xffffffff)
    dex = bytes(dex)

    with zipfile.ZipFile(src_apk) as zin, zipfile.ZipFile(dst_apk, 'w', zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = dex if item.filename == 'classes.dex' else zin.read(item.filename)
            zout.writestr(item, data)
    print('patched module written:', dst_apk)

if __name__ == '__main__':
    main()
