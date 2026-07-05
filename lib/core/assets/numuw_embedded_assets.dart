import 'dart:convert';
import 'dart:typed_data';

/// Embedded Numuw reference artwork for deterministic visual previews.
class NumuwEmbeddedAssets {
  const NumuwEmbeddedAssets._();

  static Uint8List get baby => base64Decode(
    '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'
  );

  static Uint8List get plant => base64Decode(
    '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'
  );

  static Uint8List get bottle => base64Decode(
    'UklGRroBAABXRUJQVlA4IK4BAACQCACdASowADAAPoE4lEelI6IhONbYAKAQCWUAykK2zcBjH+f1/EJ07Q/7/4lnTcQYxve5'
    '3LCcEIveDs1UAfz5YT0/+21EOaNRbhR4gAD+/fee/6oDl9RsKCOlA+8XdaOa+ZEL399g6qgxszSsjXn/nOCnadIKTTtJBtuR'
    'G+faGdsSGKtYF6l08chaT96v6OmFmeQJA9T8+ZikUff0k5e0RsK2Jp60f9xzGrKfyD7QQlwpXKBuU15LTYBy+j7JSUCh99UC'
    '1tO4uO1Ufs5lqB+v6f8UUecR0VxBNozQiAxyYM8rR5o75pWwBjuGQRIyzH0toiH7xtm4oinh7/mgSKODK14JsGW7KaFqL+vw'
    '/HC41blUxMorpXb5qLI6V9Ihee93fYnSjJD4mkJeg83B//66lzeXoefhNboweZrBdwAMLHk43t2IAZ66YiCZWEqcBDob4WGZ'
    'kro9XCJP8ajf1MVJJ4i8FfYgnsjJr7pILLq6Sp7ELEJ068P/+Q8Ac4UbcJaalpysOmx6DKCoAUzxop6wBx74TLug7ySeHFFW'
    't8nEus8plmMCN1nEQA4AUCAA'
  );

  static Uint8List get diaper => base64Decode(
    'UklGRtABAABXRUJQVlA4IMQBAABQCQCdASowADAAPpE8mUmloyIhKrVcALASCWcAykD11aP6pZm7BD6XMdhsIgWgNQuc51aH'
    '8fJ4tKJ18O6O8iAMxJxokDLQmSDkk40pmrxhOvY1QAD+/nvnpW57i+GxhpCnufaWDcCGiwvtp5sGdaLTmcdL+Ai897GaKCXA'
    'D5UMGeMRHYKk4gSxAbfHEuFusOKz9FTRm2TnHZ0Hg+zwpP7CUekTnXB0pV0Cffa3Ww1HJQ5/nJMM/TfTL5jn/zuAAYcvUxXI'
    'mJMqslNX5jRpSymu1vEV5j7f93n0H8j4lxsuFPM21vZj5XGL+L5Idhs/gfT+yf5AdHtavfc+kdULOvBv4X+vsfhmie6yQfdr'
    'tahpMoHgAiDpbLC0Y68sdyrv+ZYfst+PDHX9JrmOKaq3ix2Shq05tBeCXw/GZwsfY15h6s3Jndp0l3PS6EJUpskp9juo6QH6'
    'Jxhi6rP1toIyNvuKr2QyTsFWLiIIPOGYXhygREeefsu1Xw3u54wRIAEcZQr9haz3OnWyGiW2zKtEHpjm72MuhFCa5hI8qKL1'
    'q/s30Tx7PvIFQ/2b7EvfaYGffxlbtO8IXg/T4iFfhkMjFwIpwMu4AA=='
  );

  static Uint8List get moon => base64Decode(
    'UklGRuIBAABXRUJQVlA4INYBAACQCQCdASowADAAPpE4lkgloyIhMdZqALASCUAZQqCZugywAamZ95UfptXhMEpqtLIC2t0X'
    'y3cSVlZT6qvELPHxfnIfKiQFQvtrk1oxF2XblI+MKIAAAP79R94/lxqxv7yY+rG74Y+Kr6JCNEFGfqvj+Zuis2fLXv/6Wuh4'
    'euCOmlZrkMzIhpdSa9i7yek/Z9g13RP/TZ7eob0aEgJhz9dy3u0H9p7sH7lu5JNZfQaBjfB+9p/kJLK88nXHcPvtg2eoAeP1'
    'SnPj+HStvUAcPtrSIku5tQPzdFrpQn+qZZ0dVyEZikAO/5cAAS44m93EzPoZaj6oN1ZMGm7VVChiIG2tSOf2W4J9Ph/11bXW'
    'jtOw67zWGkiyaLaeQFbglmjn+WgYZqDeWD9voiYh98paUOyZA73dzU123yFAbeTCSRRDfjdOvtq3zK/7I7jguNeW4xgwdGqy'
    'ODZJrxQxoMa8jAc4I8FqKOwEGlyn2VDMRqGuyfCbXNOfxZTLBdbTGlO7mMp1ZGg0/D6IgIKaGQmmuydTs/3sX9aA3uSMD+6L'
    'BZYufMCXvrXcaQqMJY2fv6XCMUbouLPXHuPjlkwFLYSknmdo+kSuSw6S4PZhWPZ7Z/5tIje3xAAAAA=='
  );

  static Uint8List get shield => base64Decode(
    'UklGRggCAABXRUJQVlA4IPwBAAAQCwCdASo4ADgAPpE+mUmloyIhLBK7MLASCWIAyLjzfHejiWazs4rNBk7TDnTiDn54/FPa'
    '2AjiLF5L6UYOr2no8b9YOKo3htX4MVpqOOCMOTOg+YshGE47lllaJfleyogAAP78PzCnFho/0LjoN8HhZPJRPYtRRi7R+LMY'
    'GCP6QsRcj9UdXa1RXaTRayI9JTZDAO5saJLy0P9ZlVXMHvTp0c/tmocWk4o28ZS/TRCtMipfdZ53dUWjzzv+MxcJye7GlPnD'
    'c1UOKHY1jp9O/KQ+Na2xDWdkfYVr8zcaVzvsBWgw7k9B0EmwhwZef+a74yB5aTkzGoWvL25PBF1ZSg7s1WI6rxebNzBpsTjj'
    '30buQwKmLDu4bNav5aApANdyDzNtLCAN4RR34DvnDPk5t1jOn3sYLMHtFus/fg2ko52vjWz3MVqXQsz+M3zopCcKtEcSJ+A7'
    'bzwAXd+/K1uvgawGdemT4qq69FQXlobRgZegti5CGmp/AA5117/sI1sVLtlJSjUzHGeQYbgvlhYodqkyPsbl9cbhGlBEyRei'
    'pxoKX+78n0uV66S4mSLBSfXhH9drFEsb9rUYENvuf1T3Gd4cE9oUXFfQycEdwhHGbzmCXEBlrpMF5Qr9zMTegRWeF/0THXej'
    'aLs/hOOENNGSkkIoOPQzizCptYL1b5AA'
  );

  static Uint8List get leafTip => base64Decode(
    'UklGRrAAAABXRUJQVlA4IKQAAAAQBQCdASogACAAPpE+m0kloyKhKAqosBIJYwC06YyMs2iJTNHu6++R3k67Up6diu+AAP7+'
    'q1ChwNdKrSnN0Z/B/TB5gssqE+Ze8DMw94wmky8Uar+/SckOnbryrkstZkl/F4upIUlkrltyICDQUIwpQrT/R2y9ATTfBgRo'
    '7cEnVSfKmtE94Taho1G6tsfsTUsg/pYwak0YjvnVmr5OkeWE/z6AAA=='
  );
}
