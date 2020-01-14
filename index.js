
import {requireNativeComponent, Platform, NativeModules, View, ViewPropTypes} from 'react-native';
import React from "react";
import PropTypes from "prop-types";
import createReactClass from "create-react-class";

'use strict';

const { RNWorldPay } = NativeModules;

export const configure = (options) => RNWorldPay.configure(options);
export const createToken = (options) => RNWorldPay.createToken(options);
export const validateCardDetails = (options) => RNWorldPay.validateCardDetails(options);

export const ApplePayButton = createReactClass({

	propTypes: {
		...ViewPropTypes,

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