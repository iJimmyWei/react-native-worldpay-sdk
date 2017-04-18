package com.cube.worldpay;

import android.support.annotation.NonNull;
import android.text.TextUtils;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.worldpay.Card;
import com.worldpay.CardValidationError;
import com.worldpay.ResponseCard;
import com.worldpay.ResponseError;
import com.worldpay.ReusableToken;
import com.worldpay.WorldPay;
import com.worldpay.WorldPayError;
import com.worldpay.WorldPayResponse;
import com.worldpay.WorldPayResponseReusableToken;

public class ReactNativeWorldpayModule extends ReactContextBaseJavaModule
{
	private static final String CLIENT_KEY_KEY = "clientKey";
	private static final String REUSABLE_KEY = "reusable";
	private static final String VALIDATION_KEY = "validation";
	private static final String CARD_NUMBER_KEY = "number";
	private static final String CARD_NAME_KEY = "name";
	private static final String CARD_CVC_KEY = "cvc";
	private static final String CARD_EXPIRY = "expiry";
	private static final String CARD_EXPIRY_MONTH_KEY = "expiryMonth";
	private static final String CARD_EXPIRY_YEAR_KEY = "expiryYear";
	private static final String TOKEN_TOKEN_KEY = "token";
	private static final String TOKEN_CVC_KEY = "cvc";

	public ReactNativeWorldpayModule(ReactApplicationContext reactContext)
	{
		super(reactContext);
	}

	@Override
	public String getName()
	{
		return "RNWorldPay";
	}

	@ReactMethod
	public void configure(@NonNull ReadableMap config)
	{
		if (config == null)
		{
			throw new IllegalArgumentException("Config is null");
		}
		else if (!config.hasKey(CLIENT_KEY_KEY))
		{
			throw new IllegalArgumentException("Client key not specified");
		}

		String clientKey = config.getString(CLIENT_KEY_KEY);

		if (TextUtils.isEmpty(clientKey))
		{
			throw new IllegalArgumentException("Client key cannot be empty");
		}

		WorldPay.getInstance().setClientKey(clientKey);

		boolean reusable = config.hasKey(REUSABLE_KEY) ? config.getBoolean(REUSABLE_KEY) : false;
		WorldPay.getInstance().setReusable(reusable);

		String validation = config.hasKey(VALIDATION_KEY) ? config.getString(VALIDATION_KEY) : null;
		Card.setValidationType("basic".equalsIgnoreCase(validation) ? Card.VALIDATION_TYPE_BASIC : Card.VALIDATION_TYPE_ADVANCED);
	}

	private Card createCardFromReadableMap(@NonNull ReadableMap map)
	{
		Card card = new Card();
		card.setCardNumber(map.hasKey(CARD_NUMBER_KEY) ? map.getString(CARD_NUMBER_KEY) : "");
		card.setCvc(map.hasKey(CARD_CVC_KEY) ? map.getString(CARD_CVC_KEY) : "");
		card.setExpiryMonth(map.hasKey(CARD_EXPIRY_MONTH_KEY) ? map.getString(CARD_EXPIRY_MONTH_KEY) : "");
		card.setExpiryYear(map.hasKey(CARD_EXPIRY_YEAR_KEY) ? map.getString(CARD_EXPIRY_YEAR_KEY) : "");
		card.setHolderName(map.hasKey(CARD_NAME_KEY) ? map.getString(CARD_NAME_KEY) : "");
		return card;
	}

	private ReusableToken createReusableTokenFromReadableMap(@NonNull ReadableMap map)
	{
		ReusableToken token = new ReusableToken();
		token.setToken(map.hasKey(TOKEN_TOKEN_KEY) ? map.getString(TOKEN_TOKEN_KEY) : "");
		token.setCvc(map.hasKey(TOKEN_CVC_KEY) ? map.getString(TOKEN_CVC_KEY) : "");
		token.setClientKey(WorldPay.getInstance().getClientKey());
		return token;
	}

	@ReactMethod
	public void createToken(@NonNull ReadableMap input, @NonNull final Promise promise)
	{
		try
		{
			Card card = createCardFromReadableMap(input);
			WorldPay.getInstance().createTokenAsyncTask(getReactApplicationContext(), card, new WorldPayResponse()
			{
				@Override
				public void onSuccess(ResponseCard responseCard)
				{
					WritableMap output = Arguments.createMap();
					output.putInt("code", 200);

					WritableMap response = Arguments.createMap();
					response.putString("token", responseCard.getToken());
					output.putMap("response", response);

					promise.resolve(output);
				}

				@Override
				public void onResponseError(ResponseError responseError)
				{
					promise.reject(Integer.toString(responseError.getHttpStatusCode()), responseError.getMessage());
				}

				@Override
				public void onError(WorldPayError worldPayError)
				{
					promise.reject(Integer.toString(worldPayError.getCode()), worldPayError.getMessage());
				}
			});
		}
		catch (Exception ex)
		{
			promise.reject(ex);
		}
	}

	@ReactMethod
	public void reuseToken(@NonNull ReadableMap input, @NonNull final Promise promise)
	{
		try
		{
			ReusableToken reusableToken = createReusableTokenFromReadableMap(input);
			WorldPay.getInstance().reuseTokenAsyncTask(getReactApplicationContext(), reusableToken, new WorldPayResponseReusableToken()
			{
				@Override
				public void onSuccess()
				{
					WritableMap output = Arguments.createMap();
					output.putInt("code", 200);
					output.putMap("response", Arguments.createMap());
					promise.resolve(output);
				}

				@Override
				public void onResponseError(ResponseError responseError)
				{
					promise.reject(Integer.toString(responseError.getHttpStatusCode()), responseError.getMessage());
				}

				@Override
				public void onError(WorldPayError worldPayError)
				{
					promise.reject(Integer.toString(worldPayError.getCode()), worldPayError.getMessage());
				}
			});
		}
		catch (Exception ex)
		{
			promise.reject(ex);
		}
	}

	/**
	 * Validates the users card details
	 */
	@ReactMethod
	public void validateCardDetails(@NonNull ReadableMap input, @NonNull Promise promise)
	{
		try
		{
			Card card = createCardFromReadableMap(input);
			CardValidationError error = card.validate();

			WritableMap output = Arguments.createMap();
			output.putBoolean(CARD_NUMBER_KEY, error != null && !error.hasError(32));
			output.putBoolean(CARD_NAME_KEY, error != null && !error.hasError(16));
			output.putBoolean(CARD_CVC_KEY, error != null && !error.hasError(8));
			output.putBoolean(CARD_EXPIRY, error != null && !error.hasError(4));
			promise.resolve(output);
		}
		catch (Exception ex)
		{
			promise.reject(ex);
		}
	}

	@ReactMethod
	public void validateCVC(@NonNull ReadableMap input, @NonNull Promise promise)
	{
		try
		{
			ReusableToken token = createReusableTokenFromReadableMap(input);
			boolean cvcError = token.validateCVC();

			WritableMap output = Arguments.createMap();
			output.putBoolean(TOKEN_TOKEN_KEY, true);
			output.putBoolean(TOKEN_CVC_KEY, cvcError);
			promise.resolve(output);
		}
		catch (Exception ex)
		{
			promise.reject(ex);
		}
	}
}
