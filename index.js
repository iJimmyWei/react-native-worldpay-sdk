
import {requireNativeComponent, Platform, NativeModules, View} from 'react-native';

const { RNWorldPay } = NativeModules;

export default RNWorldPay;

'use strict';

import React from "react";
import PropTypes from "prop-types";

export const ApplePayButton = React.createClass({

	propTypes: {
		...View.propTypes,

		/**
		 * Whether the button is enabled
		 */
		enabled: PropTypes.bool,

		/**
		 * An callback when the button is pressed
		 */
		onPress: PropTypes.func,

		/**
		 * The type of button to display this as
		 *
		 * Note:
		 * - setup is only available iOS > 9.0
		 * - inStore is only available iOS > 10.0
		 * - donate is only available iOS > 10.3
		 * Providing an unavailable option will fall back to `plain`
		 */
		type: PropTypes.oneOf(['plain','buy','setup','inStore','donate']),

		/**
		 * The style of the Apple Pay button
		 */
		buttonStyle: PropTypes.oneOf(['black','white','whiteOutline'])
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