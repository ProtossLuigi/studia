import sys


def encode_char(c):
    if c < 26:
        return bytes([ord('A') + c])
    elif c < 52:
        return bytes([ord('a') + c - 26])
    elif c < 62:
        return bytes([ord('0') + c - 52])
    elif c == 62:
        return b'+'
    elif c == 63:
        return b'/'
    else:
        raise ValueError('error')


def decode_char(c):
    if c == ord(b'='):
        return -1
    elif c == ord(b'+'):
        return 62
    elif c == ord(b'/'):
        return 63
    elif c <= ord(b'9'):
        return 52 + c - ord('0')
    elif c <= ord(b'Z'):
        return c - ord('A')
    elif c <= ord(b'z'):
        return 26 + c - ord('a')
    else:
        raise ValueError('error')


def encode(msg):
    encoded = b''
    while True:
        if msg == b'':
            break
        encoded += encode_char(msg[0] >> 2)
        if len(msg) < 2:
            encoded += encode_char(msg[0] % 4 << 4)
            encoded += b'=='
            break
        else:
            encoded += encode_char((msg[0] % 4 << 4) + (msg[1] >> 4))
            if len(msg) < 3:
                encoded += encode_char(msg[1] % 16 << 2)
                encoded += b'='
                break
            else:
                encoded += encode_char((msg[1] % 16 << 2) + (msg[2] >> 6))
                encoded += encode_char(msg[2] % 64)
                msg = msg[3:]
    return encoded


def decode(encoded):
    decoded = b''
    try:
        while True:
            if encoded == b'':
                break
            if len(encoded) < 4:
                raise ValueError('error')
            block = [decode_char(encoded[i]) for i in range(0, 4)]
            if block[0] == -1 or block[1] == -1 or (block[2] == -1 and block[3] != -1):
                raise ValueError('error')
            decoded += bytes([(block[0] << 2) + (block[1] >> 4)])
            if block[2] == -1:
                break
            else:
                decoded += bytes([(block[1] % 16 << 4) + (block[2] >> 2)])
                if block[3] == -1:
                    break
                else:
                    decoded += bytes([(block[2] % 4 << 6) + block[3]])
                    encoded = encoded[4:]
    except ValueError as e:
        print('incorrect encoding')
        return ''
    else:
        return decoded


f = open(sys.argv[2], 'rb')
inmsg = f.read()
f.close()
outmsg = b''
if sys.argv[1] == '--encode':
    outmsg = encode(inmsg)
elif sys.argv[1] == '--decode':
    outmsg = decode(inmsg)
f = open(sys.argv[3], 'wb')
f.write(outmsg)
f.close()
