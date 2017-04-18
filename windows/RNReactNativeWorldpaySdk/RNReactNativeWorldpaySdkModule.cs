using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Com.Reactlibrary.RNReactNativeWorldpaySdk
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNReactNativeWorldpaySdkModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNReactNativeWorldpaySdkModule"/>.
        /// </summary>
        internal RNReactNativeWorldpaySdkModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNReactNativeWorldpaySdk";
            }
        }
    }
}
