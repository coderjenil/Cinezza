package djmixer.virtual.remixsong.remixsong

import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class NativeAdFactoryCustom(private val layoutInflater: LayoutInflater) : NativeAdFactory {
    
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        
        val adView = layoutInflater.inflate(R.layout.custom_native_ad, null) as NativeAdView

        // Bind views - ALL required for validator
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        adView.bodyView = adView.findViewById(R.id.ad_body)
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        adView.iconView = adView.findViewById(R.id.ad_app_icon)
        adView.mediaView = adView.findViewById(R.id.ad_media)
        adView.starRatingView = adView.findViewById(R.id.ad_stars)
        adView.advertiserView = adView.findViewById(R.id.ad_advertiser)
        adView.storeView = adView.findViewById(R.id.ad_store)
        adView.priceView = adView.findViewById(R.id.ad_price)

        // Populate headline (required)
        (adView.headlineView as TextView).text = nativeAd.headline

        // Populate MediaView (required)
        adView.mediaView?.setMediaContent(nativeAd.mediaContent)

        // Optional: Body
        adView.bodyView?.let { bodyView ->
            if (nativeAd.body != null) {
                (bodyView as TextView).text = nativeAd.body
                bodyView.visibility = View.VISIBLE
            } else {
                bodyView.visibility = View.GONE
            }
        }

        // Optional: Call to action
        adView.callToActionView?.let { ctaView ->
            if (nativeAd.callToAction != null) {
                (ctaView as Button).text = nativeAd.callToAction
                ctaView.visibility = View.VISIBLE
            } else {
                ctaView.visibility = View.INVISIBLE
            }
        }

        // Optional: Icon
        adView.iconView?.let { iconView ->
            if (nativeAd.icon != null) {
                (iconView as ImageView).setImageDrawable(nativeAd.icon?.drawable)
                iconView.visibility = View.VISIBLE
            } else {
                iconView.visibility = View.GONE
            }
        }

        // Optional: Star rating
        adView.starRatingView?.let { starView ->
            if (nativeAd.starRating != null) {
                (starView as RatingBar).rating = nativeAd.starRating!!.toFloat()
                starView.visibility = View.VISIBLE
            } else {
                starView.visibility = View.GONE
            }
        }

        // Optional: Advertiser
        adView.advertiserView?.let { advView ->
            if (nativeAd.advertiser != null) {
                (advView as TextView).text = nativeAd.advertiser
                advView.visibility = View.VISIBLE
            } else {
                advView.visibility = View.GONE
            }
        }

        // Optional: Store
        adView.storeView?.let { storeView ->
            if (nativeAd.store != null) {
                (storeView as TextView).text = nativeAd.store
                storeView.visibility = View.VISIBLE
            } else {
                storeView.visibility = View.GONE
            }
        }

        // Optional: Price
        adView.priceView?.let { priceView ->
            if (nativeAd.price != null) {
                (priceView as TextView).text = nativeAd.price
                priceView.visibility = View.VISIBLE
            } else {
                priceView.visibility = View.GONE
            }
        }

        // Register the native ad
        adView.setNativeAd(nativeAd)

        return adView
    }
}
