# AsmGrm

AsmGrm is an anagram generator written in x86-64 assembly and integrated with [FastCGI][1]. The only supported platform is linux x86-64.

## Getting started

A [Vagrantfile][2] is provided for easy setup:

    vagrant up

This should spin up a VM, install dependencies, build AsmGrm and start [Nginx][3]. By default the VM is started with a static IP of 10.255.255.122.

When restarting the VM you'll need to start-up AsmGrm manually:

    vagrant ssh
    cd /vagrant
    make run

## License

    Copyright (C) 2014 Rob Hardwick

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
    EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[1]: http://www.fastcgi.com
[2]: http://www.vagrantup.com
[3]: http://nginx.org
