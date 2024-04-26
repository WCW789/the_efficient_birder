# The Efficient Birder

The Efficient Birder is an image classification app that identifies the bird in a picture for you. A user can also view a list of the birds they've seen on their homepage. Adding in new entries of birds seen involves manual work that could be bypassed. By effectively utilizing a convolutional neural net, in this case a pre-trained model called MobileNetV3 for the MVP, birders can avoid typing or writing in information and instead have relevant details automatically populated for them.

## Table of Contents
- [Main Features](#main-features)
- [Technologies Used](#technologies-used)
- [Installation](#installation)
- [Other](#other)

## Main Features

The landing page showcases all the birds that the user has seen already. Entries are automatically sorted in order of latest bird spotted, but users have the ablity to sort by name or change the date order. They can also search by name of bird:

<img width="1394" alt="Homepage of birding journal" src="https://github.com/WCW789/the_efficient_birder/assets/32531807/c6cc40c0-74fa-4aea-becf-7c4199c7eb12">

If a user wants to add a new entry, they would click on "New Bird". This would take them to the camera option. After they have captured an image, the image data will be sent to an AWS S3 bucket; an object url from S3 is then sent to a Flask server where the pre-trained model works on the identification. Once the classiciation is complete, the name is rendered on the UI:

<img width="402" alt="Camera capture view" src="https://github.com/WCW789/the_efficient_birder/assets/32531807/879241dd-a1ca-4f42-9287-d1ff48030597">

Users have the ability to upload an image as well. There is a slightly different flow; the assumption is that since the user is at their computer, they are not where they saw the bird and so the date and location cannot be automatically captured. The user can enter a physical address, and the Mapbox API is utilized to capture the latitude and longitude from that address:

<img width="1396" alt="Uploading an image" src="https://github.com/WCW789/the_efficient_birder/assets/32531807/56fd3422-debd-4c5c-8f7c-bc5cbbea802f">

Once an image is captured or uploaded, an entry will be created much like the following:

<img width="454" alt="Example of journal entry" src="https://github.com/WCW789/the_efficient_birder/assets/32531807/508b9ef5-d412-45db-92b8-d47194dc5e79">


## Technologies Used

```
Rails 7
Requires Python used in separate repo to function: https://github.com/WCW789/bird_recognition
HTML/CSS/Javascript
```

## Installation

To install and run, please use the following commands:

```
bundle install
rails db:create
rails db:migrate
rails server
```

## Other

Tasks for this project was organized in Github Projects: https://github.com/users/WCW789/projects/1
