# Scrolln

Scrolln is a macOS application that provides a simple and intuitive way to control the natural scrolling direction for connected input devices. It allows you to customize the scrolling behavior for mice and trackpads connected to your Mac, making it easy to adapt to your preferences.

## Features

- **Device List**: View a list of connected input devices, including mice.
- **Natural Scrolling**: Toggle natural scrolling direction for each device individually.
- **Persistence**: Your customization preferences are persisted and applied automatically on each application launch.

## How to Use

1. **Device List**: Launch the application to view the list of connected devices.

2. **Natural Scrolling**: For each device listed, you can toggle the "Natural Scroll" switch to enable or disable natural scrolling based on your preference.

3. **Quit Application**: You can quit the application using the "Quit" button at the bottom of the device list. If you do so, the initial scrolling direction (before launching the App) will be reused again.

## Building and Running

### Requirements

- macOS 10.15 or later

### Build Instructions

1. Open the `Scrolln.xcodeproj` file in Xcode.
2. Build the project using the Xcode build and run commands.

### Running the Application

1. Build the project using Xcode.
2. Launch the built application.

## How It Works

Scrolln utilizes the IOKit framework to interact with connected input devices. It registers callbacks to be notified of device connection and disconnection events. The application stores user preferences using a simple JSON file, ensuring that your customization choices persist across launches.

## Contribution

Feel free to contribute to the project by submitting bug reports, feature requests, or pull requests. Your input is valuable!

## License

Scrolln is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

