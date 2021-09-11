import json
import unittest
import json

import src.handler as handler

class TestHandler(unittest.TestCase):
    def test_decrypt_zip(self):
        body = {
            "password": "AOMH9603288A3",
            "file_name": "test",
            "file": "UEsDBBQDAAAAAINSK1MAAAAAAAAAAAAAAAAMAAAAdGVzdF9mb2xkZXIvUEsDBDMDAQBjAFpSK1MAAAAAQQAAACUAAAAUAAsAdGVzdF9mb2xkZXIvdGVzdC50eHQBmQcAAgBBRQMAAK15p1yL05nQbCyWYDzgIoaWgLtUfE8pJhGJi+FCxbet59NcavzmEIY8ipiaZT6+zdehwKVfzKSdc18QuRCKm0l2UEsBAj8DFAMAAAAAg1IrUwAAAAAAAAAAAAAAAAwAJAAAAAAAAAAQgO1BAAAAAHRlc3RfZm9sZGVyLwoAIAAAAAAAAQAYAAAnmEMxp9cBACeYQzGn1wEAJ5hDMafXAVBLAQI/AzMDAQBjAFpSK1MAAAAAQQAAACUAAAAUAC8AAAAAAAAAIICkgSoAAAB0ZXN0X2ZvbGRlci90ZXN0LnR4dAoAIAAAAAAAAQAYAIAP5BYxp9cBACeYQzGn1wEAJ5hDMafXAQGZBwACAEFFAwAAUEsFBgAAAAACAAIAzwAAAKgAAAAAAA=="
        }
        body = json.dumps(body)

        payload = {
            "body": body,
        }

        response = handler.decrypt_zip(payload, None);
        resBody = json.loads(response["body"])
        
        expectedB64FileLen = 368
        
        self.assertEqual(len(resBody["file"]), expectedB64FileLen)

if __name__ == '__main__':
    unittest.main()