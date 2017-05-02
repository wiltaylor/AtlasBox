# AtlasBox
This is a Powershell module for managing box files hosted on Hashicorp's Atlas service.

## What is all of this.
Atlas is a service for hosting services for Hashicorp's online services. This module deals with Boxes which are image files used by Vagrant to create a virtual environment.

If all of this doesn't make much sense to you I would suggest going to the following web sites:

[Vagrant](https://www.vagrantup.com)

[Packer](https://www.packer.io)

## How to install
To install run the following command and agree to any prompts:

`` Install-Module AtlasBox ``

## How to use
Before you can upload box images to atlas you must first create an account and understand how the objects relate to each other.

Sign up an account [here](https://atlas.hashicorp.com/account/new).

### Box
This is the highest level of object in the tree. This is the name of the box which is used in vagrant. You need to create a box before you can create any other type of object.

### Version
A version is the next level down the object tree. These as the name suggests allows you to store versions of a box. The highest version box which is published (or released using Hashicorp's language) will be what vagrant retrives.

### provider
This is the lowest level object which contains the actual box image. A provider is used to specify an image for a provider that vagrant would use.

An example is you would create a provider for vmware_desktop if you wanted vmware workstation to use a specific image and you would create a provider for virtualbox if you had an image for it.

You can have multiple providers for each version.

You can get more information on how this all works in Hashicorp's documentation [here](https://atlas.hashicorp.com/help/vagrant/boxes).

## Examples
How to login:

``` Set-AtlasToken -Token $mytoken -Username wiltaylor ```

Note: To get a atlas token please read the instructions [here](https://atlas.hashicorp.com/help/user-accounts/authentication).

How to create a new box:

``` New-AtlasBox -Name MyBox ```

How to create a new version:

``` New-AtlasBoxVersion -Name MyBox -Version 1.0.0 ```

How to create a new provisioner:

``` New-AtlasBoxProvider -Name MyBox -Version 1.0.0 -New-AtlasBoxProvider vmware_desktop ```

How to upload a box image.

``` Send-AtlasBoxProvider -Name MyBox -Version 1.0.0 -New-AtlasBoxProvider vmware_desktop -Filename c:\boxes\mybox.box ```

How to log out:

``` Clear-AtlasToken ```

## License
Copyright 2017 Wil Taylor

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

