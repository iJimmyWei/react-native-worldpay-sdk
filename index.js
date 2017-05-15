
import {requireNativeComponent, Platform, NativeModules, View} from 'react-native';

const { RNWorldPay } = NativeModules;

export default RNWorldPay;

'use strict';

import React, {PropTypes} from "react";

export const ApplePayButton = React.createClass({

	propTypes: {
		...View.propTypes,

		/**
		 * Whether the button is enabled
		 */
		enabled: React.PropTypes.bool,

		/**
		 * An callback when the button is pressed
		 */
		onPress: React.PropTypes.func,

		/**
		 * The type of button to display this as
		 *
		 * Note:
		 * - setup is only available iOS > 9.0
		 * - inStore is only available iOS > 10.0
		 * - donate is only available iOS > 10.3
		 * Providing an unavailable option will fall back to `plain`
		 */
		type: React.PropTypes.oneOf(['plain','buy','setup','inStore','donate']),

		/**
		 * The style of the Apple Pay button
		 */
		buttonStyle: React.PropTypes.oneOf(['black','white','whiteOutline'])
	},

	getDefaultProps() {
		return {
			type: 'plain',
			buttonStyle: 'black'
		}
	},

	_onPress() {
		this.props.onPress && this.props.onPress();
	},

	render() {

		if (Platform.OS === "android") {
			return null;
		} else if (Platform.OS === "ios") {
			return (
				<ButtonNative {...this.props} onPress={this._onPress}/>
			);
		}
	}
});

if (Platform.OS === "ios") {
	var ButtonNative = requireNativeComponent('RNApplePayButton', ApplePayButton);
}