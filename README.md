# Simple Elemental Video
Deploy a simple aws video pipeline

# Cloudformation Docs
[MediaConnect](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_MediaConnect.html)

[MediaLive](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_MediaLive.html)

[MediaPackage](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_MediaPackage.html)

# Prerequisites
- [Docker](https://www.docker.com/get-started)
- [Aws Cli](https://aws.amazon.com/cli)
- Make

# Login to Your Aws Account
You can set the environment variables manually or

```sh
eval "$(aws configure export-credentials --profile your-profile-name --format env)"
```

Export a region
```sh
export AWS_REGION=eu-west-1
```

# Run Everything at Once
> For security, we whitelist your public ip on mediaconnect, which means if you have a carrier NAT, you might not be able to push video, in that case, change [this](./main.tf#20) to `0.0.0.0/0`

Run the following command from the terminal
```sh
make deploy
```
This should print a playback url

# Playback
You can use [hls.js](https://hlsjs.video-dev.org/demo) to playback your video
or run the following command to get a prepared url


```sh
make print-hls-playback-url
```

# Destroy Everything
Run the following command from the terminal
```sh
make destroy
```
