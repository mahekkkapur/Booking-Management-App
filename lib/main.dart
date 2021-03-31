import 'package:econoomaccess/Homemaker/Chat/Makerchat.dart';
import 'package:econoomaccess/Homemaker/Loyalty_pages/LoyaltyPage.dart';
import 'package:econoomaccess/Homemaker/Profile_setup/AddDetailsMaker.dart';
import 'package:econoomaccess/Homemaker/bottom_nav/MenuPage.dart';
import 'package:econoomaccess/Homemaker/bottom_nav/MerchantOrder.dart';
import 'package:econoomaccess/Homemaker/bottom_nav/recommended.dart';
import 'package:econoomaccess/User_Section/Drawer/Your_orders/Order/ChooseOrderToTrack.dart';
import 'package:econoomaccess/User_Section/Drawer/Your_orders/Order/TrackOrder.dart';
import 'package:econoomaccess/User_Section/Drawer/Your_orders/VendorLocation.dart';
import 'package:econoomaccess/User_Section/Drawer/Your_orders/ExistingOrder.dart';
import 'package:econoomaccess/Homemaker/Profile_setup/MakerAddProfilePhotoPage.dart';
import 'package:econoomaccess/Homemaker/Profile_setup/Intro/MakerInstructions.dart';
import 'package:econoomaccess/Homemaker/orders/ReviewOrder.dart';
import 'package:econoomaccess/User_Section/profile_setup/UpdateMapPage.dart';
import 'package:econoomaccess/User_Section/Bottom_nav/UserProfilePage.dart';
import 'package:econoomaccess/User_Section/Bottom_nav/favourites/ProfilePage.dart';
import 'package:econoomaccess/User_Section/cart/SelectAddress.dart';
import 'package:econoomaccess/User_Section/profile_setup/allergies.dart';
import 'package:econoomaccess/Homemaker/drawer/analytics.dart';
import 'package:econoomaccess/User_Section/bottomBar.dart';
import 'package:econoomaccess/Homemaker/bottomBarMaker.dart';
import 'package:econoomaccess/Homemaker/Profile_setup/business_location.dart';
import 'package:econoomaccess/Homemaker/each_dish_review_page.dart';
import 'package:econoomaccess/Homemaker/bottom_nav/homemaker_profile.dart';
import 'package:econoomaccess/Homemaker/Payment/payouts.dart';
import 'package:econoomaccess/Homemaker/Promotion/promotionList.dart';
import 'package:econoomaccess/splash_screens/splash.dart';
import 'package:provider/provider.dart';
import 'package:econoomaccess/User_Section/Bottom_nav/favourites/favorites_screen.dart';
import 'package:econoomaccess/common/chats/chat.dart';
import 'package:flutter/material.dart';
import 'package:econoomaccess/User_Section/Bottom_nav/search_screen.dart';
import 'AuthChoosePage.dart';
import 'package:econoomaccess/Homemaker/bottom_nav/EditPage.dart';
import 'package:econoomaccess/User_Section/Bottom_nav/explore_page/ExplorePage.dart';
import 'package:econoomaccess/common/onboard_screens/OnBoardPage.dart';
import 'package:econoomaccess/Homemaker/signUp/SignUpPage.dart';
import 'User_Section/profile_setup/UserDetailsPage.dart';
import 'User_Section/profile_setup/foodPref.dart';
import 'localization/appLocalization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:econoomaccess/User_Section/profile_setup/ProfileSetUpIntroPage.dart';
import 'localization/language_constants.dart';
import 'User_Section/Bottom_nav/favourites/recepie_screen.dart';
import 'package:econoomaccess/Homemaker/New_item/new_item.dart';
import 'User_Section/profile_setup/UserAddProfilePhotoPage.dart';
import 'package:econoomaccess/Homemaker/Profile_setup/Intro/MakerOnBoardPage.dart';
import 'package:econoomaccess/Homemaker/Promotion/PromotionsPage.dart';

import 'package:econoomaccess/add_recipe/pricemodel.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (this._locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800])),
        ),
      );
    } else {
      return ChangeNotifierProvider(
        create: (context) => PriceModel(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: _locale,
          supportedLocales: [
            Locale("en", "US"),
            Locale("bn", "IN"),
            Locale("gu", "IN"),
            Locale("hi", "IN"),
            Locale("kn", "IN"),
            Locale("ml", "IN"),
            Locale("mr", "IN"),
            Locale("pa", "IN"),
            Locale("ta", "IN"),
            Locale("te", "IN"),
            Locale("ur", "IN")
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          title: "Naniz Eats",
          home: SplashScreen(),
          theme: ThemeData(
            appBarTheme: AppBarTheme(
                iconTheme: IconThemeData(color: Colors.black),
                color: Colors.grey[50],
                elevation: 0,
                textTheme: TextTheme(
                    headline6: TextStyle(
                  fontFamily: "Gilroy",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ))),
            textTheme: TextTheme(
              headline6: TextStyle(
                fontFamily: "Gilroy",
              ),
              headline4: TextStyle(
                fontFamily: "Gilroy",
              ),
              headline5: TextStyle(
                fontFamily: "Gilroy",
              ),
              button: TextStyle(
                fontFamily: "Gilroy",
              ),
              caption: TextStyle(
                fontFamily: "Gilroy",
              ),
              bodyText2: TextStyle(
                fontFamily: "Gilroy",
              ),
              bodyText1: TextStyle(
                fontFamily: "Gilroy",
              ),
            ),
          ),
          routes: <String, WidgetBuilder>{
            "/SignUpPage": (BuildContext context) => SignUpPage(),
            "/OnBoardPage": (BuildContext context) => OnBoardPage(),
            "/ProfileSetUpIntroPage": (BuildContext context) =>
                ProfileSetUpIntoPage(),
            "/UserDetailsPage": (BuildContext context) => UserDetailsPage(),
            "/MenuPage": (BuildContext context) => MenuPage(),
            "/EditPage": (BuildContext context) => EditPage(),
            "/AuthChoosePage": (BuildContext context) => AuthChoosePage(),
            "/ExplorePage": (BuildContext context) => ExplorePage(),
            "/FoodPrefPage": (BuildContext context) => FoodPref(),
            "/SearchPage": (BuildContext context) => SearchScreen(),
            "/ProfilePage": (BuildContext context) => ProfilePage(),
            "/ChatPage": (BuildContext context) => ChatScreen(),
            "/RecipePage": (BuildContext context) => RecipeScreen(),
            "/FavoriteScreenPage": (BuildContext context) => FavoritesScreen(),
            "/NewItemPage": (BuildContext context) => NewItem(),
            "/ReviewOrderPage": (BuildContext context) => ReviewOrder(),
            "/MerchantOrderPage": (BuildContext context) => MerchantOrder(),
            "/UserAddProfilePhotoPage": (BuildContext context) =>
                UserAddProfilePhotoPage(),
            "/MakerAddProfilePhotoPage": (BuildContext context) =>
                MakerAddProfilePhotoPage(),
            "/MakerOnBoardPage": (BuildContext context) => MakerOnBoardPage(),
            "/AddDetailsMakerPage": (BuildContext context) => AddDetailsMaker(),
            "/MakerInstructionsPage": (BuildContext context) =>
                MakerInstructions(),
            "/MakerChatPage": (BuildContext context) => MakerChatScreen(),
            "/BuissnessLocationPage": (BuildContext context) =>
                BusinessLocation(),
            "/UserProfilePage": (BuildContext context) => UserProfilePage(),
            "/LoyaltyPage": (BuildContext context) => LoyaltyPage(),
            "/AnalyticsPage": (BuildContext context) => Analytics(),
            "/PromotionListPage": (BuildContext context) => PromotionList(),
            "/ExistingOrders": (BuildContext context) => ExistingOrders(),
            "/TrackOrder": (BuildContext context) => TrackOrder(),
            "/VendorLocation": (BuildContext context) => VendorLocation(),
            "/ChooseTrackOrder": (BuildContext context) => ChooseTrackOrder(),
            "/PromotionPage": (BuildContext context) => PromotionsPage(),
            "/PayoutPage": (BuildContext context) => Payouts(),
            "/HomemakerProfilePage": (BuildContext context) =>
                HomemakerProfile(),
            "/RecommendedPage": (BuildContext context) => Recommended(),
            "/AllergiesPage": (BuildContext context) => Allergies(),
            "/each-dish-review-page": (BuildContext context) =>
                EachDishReviewPage(),
            "/SelectAddress": (BuildContext context) => SelectAddress(),
            "/UpdateMapPage": (BuildContext context) => UpdateMapPage(),
            "/BottomBarPage": (BuildContext context) => BottomBar(),
            "/BottomBarMakerPage": (BuildContext context) => BottomBarMaker(),
          },
        ),
      );
    }
  }
}
