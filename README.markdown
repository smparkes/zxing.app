# Screen shot

http://dl.dropbox.com/u/11615635/zxing.app.png

# THIS IS A REAL WORK IN PROGRESS

This is a bare bones macruby app that demonstrates the use of zxing to
decode QR codes.

I used it to play with macruby and to do some prototyping/development
of zxing-based stuff.

It has its own packaging stuff which might be (out)dated.

It needs libicns.

You need to have macruby installed. I use rvm and macruby-nightly. You
need to have xcode installed but you don't need to run it
yourself. Running rake will call it from the command line.

Clone the repo, then do a "git submodule update --init" to pull in
zxing (kinda big).

Then, *in a non-macruby ruby*, run rake. (At least right now, rake
under macruby doesn't seem to like shelling out to run xcodebuild).

This will build zxing.app and run it. Presuming you're running on a
mac with an iSight camera, it'll pop up a window and start
decoding. All it does right now is pop up the text when it decodes a
code.

There are some rake tasks for packing the resulting app as a bundle but
that stuff in particular is dated.

Feel free to submit patches and/or other contributions.

## LICENSE:

(The MIT License)

Copyright (c) 2011 {Steven Parkes}[http://github.com/smparkes]

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
