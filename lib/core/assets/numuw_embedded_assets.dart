import 'dart:convert';
import 'dart:typed_data';

/// Embedded Numuw reference artwork used by the pixel-perfect design preview.
///
/// Keeping these small reference assets in source makes the preview reproducible
/// on CI without depending on local, untracked files. Production assets can be
/// moved to `assets/images` after the visual QA pass.
class NumuwEmbeddedAssets {
  const NumuwEmbeddedAssets._();

  static Uint8List get baby => base64Decode(
''
        'iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAABvPklEQVR4nK3995NsWZLfiX2OuCJU6qerXlV1dXX3tAQWGGB3AM5AkCBILmn7767ZrpG2ZrsDDAYDzI5sXVVdT6cMddUR/MHPuXHz1WsQpDHK8lVmZGTEvef4cfF196+rzevfxIgCa7BlTVFWGFuAMhAVMQaiikCEwPhQ4zcKlX+IEInj9+MjTv9Q3/97IDJ5g8nPevKK/JIYD288fqtATd9R5f+pw3Uo7n9/7xpVei6OnxGn7/HtP0jPvHfd+Y/yhccov1Lq/kvj/Xs6fP7kd+P/7l+bmt73ZBHidEHHd53e9P2/yc9abUuUMZiiRNsCpa1sQJArlQXPX+r9nXv/EyeL/AFBUOrDr53e3Lfv4r/uMS5g/C/8kZr87wMLM17mhzZEyfPjJcf7r08vu3e7hxcDahTv/+8f8bB293f/vhBN318pFOpwYJR6X1xRgC3mK7Q1GFsCEELa9BjGl6p7G/Xtkxbf3/TpQ00vbnKB96T+/kUfXvJBsf7Ae/2+30/e40MyMT4X0hH60GJ9eEvvf766f7kRUPFw69+6pvffJY4aLE60WTyoi3sa956k/T5tN/7FB46VOug1FUOfDrknxDBZg4lSzYdZxVEZKKXvqeW8UNPTkD//sM/Tm1EHtTWqXIW+tzrqYFZ+z8YfZDMvuDqYmXj/NMe0cPHeKQr55sbfTwXv3gH7gCxMTY9SKslyPAgASt4vvnd47ymTeF+7TO6JfE+T7w/3Mb3U9645rZua7NH0OvOK2BjS5sWAmhjVe2f2A+r8/sn49kUrpb/1WqXUqFHjZGPVKNXplekC1dQejm8f7930+6ZVZZ9kPCT5GzXaYpU3BBCDrdLfjZL+PQol5Tk6jrjxwI+pqcnInRrFnPaTE5fsD8jIl67eSiqeX0X0WVqkdG5tyyz5W2u1skc9o8TL+LAbO+dtWEUXPF6HMobK1Ny8+44qHp12d/cr+5cdu4cvrCvCccc4ZDg3LpHeBZQeBPlMp/zAgOQoND/7e+P9AQNFvkGIzAPxs8S3r9/M0N9YxkigYRRJ1NESYLW34d0AVb1ic/We3ns627N/eaQ9vnL31WK95XDYoZRQ13WAqBJOVM/h+xDX/60NLw2BcI0MKKogKC5ReYvIRX4W0s4v+JLzP9OZtdkozSaCZssZvY/YRIW38Ola0Wwv2V5e49yJrn1lt38Kwby2RasmHOqqq7B6joEByYEzqZbKnK/SX+kKjPj/Kv0elwGhbBkAAAAASUVORK5CYII='
  );

}
