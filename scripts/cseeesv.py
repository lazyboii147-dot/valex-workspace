import pandas as pd
import io

csv_data = """CATEGORY,KEY,VALUE
Cookie & Consent,Cookies Settings,Cookie Settings
Cookie & Consent,Confirm,Confirm
Cookie & Consent,Allow All,Allow All
Cookie & Consent,Manage Preferences,Manage Preferences
Cookie & Consent,Accept All Cookies,Accept All Cookies
Cookie & Consent,Accept Cookies,Accept Cookies
Cookie & Consent,Accept,Accept
Cookie & Consent,Decline,Decline
Cookie & Consent,Essential,Essential
Cookie & Consent,Marketing,Marketing
Cookie & Consent,Analytical,Analytical
Cookie & Consent,Cookie Preferences,Cookie Preferences
Cookie & Consent,Cookie Info,"We use cookies and other techniques to improve and personalise your experience on our website. Cookies are used for ads personalization"
Cookie & Consent,Essential Cookie Info,Essential cookies are necessary for the website to function...
Cookie & Consent,Cookie Info New,This site uses cookies to analyze traffic and for personalized ads measurement purposes.
Cookie & Consent,Analytical Cookie Info,Analytical cookies are used to help us understand how visitors interact...
Marketing & Promotions,Headline here,Top offers of the week!
Marketing & Promotions,Subline here,Sign up Now!
Marketing & Promotions,Visit Plan,View Plan
Marketing & Promotions,weekend promotion,Try the fastest VPN on the market.
Marketing & Promotions,weekend promotions,Try the fastest VPN on the market.
Marketing & Promotions,do not miss our,Invest in your security online!
Marketing & Promotions,Best black friday,Early Black Friday
Marketing & Promotions,Offers coming soon,offers for a limited time only
Category Sections,category_section_title,Searching for something more specific?
Category Sections,category_section_subtitle,Learn more about the best weightloss sites...
Category Sections,comparison_section_title,Which is the right Weight Loss site for you?
Category Sections,top3_section_title,Additional Recommended providers
Legal & Disclosure,Rating info text,This website receives compensation...
Legal & Disclosure,Rating info new,This website receives compensation...
Legal & Disclosure,How do we rate?,Advertising Disclosure
Language Learning,Ll_group,In a group
Language Learning,Ll_privately,Privately
Language Learning,Startnew,I want to start learning a new language
Language Learning,Practicecurrent,I want to practice my current level
Language Learning,Improvelanguage,I want to improve my language skills
Language Learning,Find out which LL app...,Find out which language app will work best for you!
Language Learning,Bridge page headline,How would you like to learn your new language?
Language Learning,Through live classes,With a tutor, through live classes
Time Commitment,1houraweek,1 hour a week
Time Commitment,2hoursaweek,2 hours a week
Time Commitment,Nowandthen,An hour every now and then
Time Commitment,Morehours,More
Dating Quiz (CD),CDquizAppearance,Appearance
Dating Quiz (CD),CDquizAvailability,Availability
Dating Quiz (CD),CDquizDiscretion,Discretion
Dating Quiz (CD),CDquizexperiment,"Experimentation ;)"
Dating Quiz (CD),CDquizExtramarital,Extramartial activity
Dating Quiz (CD),CDquizIncome,Income
Dating Quiz (CD),CDquizNotsure,Not sure yet
Dating Quiz (CD),CDquizPersonality,Personality
Dating Quiz (CD),CDquizPrice,Price
Dating Quiz (CD),CDquizStrings,No strings attached relationship
Dating Quiz (CD),CDquizUsers,Number of users
Dating Quiz (CD),CDquizDiscretion1,Discretion
Dating Quiz (SD),SDQuizCompanion,Campanionship
Dating Quiz (SD),SDQuizFlirt,Flirting
Dating Quiz (SD),SDQuizNoStrings,No strings attached
Dating Quiz (SD),SDQuizAppearance,Appearance
Dating Quiz (SD),SDQuizIncome,Income
Dating Quiz (SD),SDQuizPersonality,Personality
Dating Quiz (SD),SDQuizYes,"yes, I have"
Dating Quiz (SD),SDQuizNo,"No, I havn't"
Dating Quiz (SD),SDQuizLove,Love
Senior Dating Quiz,SeniorQuizYes,"Yes, I have"
Senior Dating Quiz,SeniorQuizNo,No, I haven't
Senior Dating Quiz,SeniorQuizLove,Love
Senior Dating Quiz,SeniorQuizCompanion,Campanionship
Senior Dating Quiz,SeniorQuizFlirt,Flirting
Senior Dating Quiz,SeniorQuizAffair,An affair
Senior Dating Quiz,SeniorQuizAppearance,Appearance
Senior Dating Quiz,SeniorQuizIncome,Income
Senior Dating Quiz,SeniorQuizPersonality,Personality
Pet & GPS,Allgps,All
Pet & GPS,Yesgps,Yes
Pet & GPS,Nogps,No
Pet & GPS,Yeswater,Yes
Pet & GPS,Nowater,No
Pet & GPS,GPScatPet,My cat
Pet & GPS,GPSdogPet,My dog
Pet & GPS,GPSadventure,My pet accompanies me on any adventure
Pet & GPS,GPSindependant,My pet goes outside independently
Pet & GPS,GPSescape,My pet is an escape artist
Pet & GPS,GPSlifestyleOther,Other
Pet & GPS,GPSactivity,I want to keep track of my pet's health and activity
Pet & GPS,GPSpetLocation,I want to know my pet's location at all times
Pet & GPS,GPSpetboth,Both
Gaming,Bg_beginner_new,Beginner
Gaming,Bg_casual,Casual
Gaming,Bg_eperienced,Experienced
Gaming,Bg_pro,Pro
Gaming,Bg_challenge,I love challenge
Gaming,Bg_stressrelieve,To relieve stress
Gaming,Bg_meetpeople,To meet people online
Gaming,Bg_fun,Just for fun
Gaming,Bg_action,Action
Gaming,Bg_strategy,Strategy
Gaming,Bg_simulation,Simulation
Gaming,Bg_fantasy,Fantasy
Gaming,Bg_farming,Farm games
Gaming,Bg_Mmo,MMO
Gaming,Simulatedbg,Simulation games
Gaming,Strategicbg,Strategic
Gaming,Adventurebg,Adventurous
Gaming,Fantasticbg,Fantasy games
Gaming,Multibg,MMO
Gaming,Skillsbg,To test my skills
Gaming,Relaxbg,To relax
Gaming,Peoplebg,To meet people
Gaming,Enjoybg,To enjoy
Gaming,PC,PC (Downloadable Games)
Gaming,Play Now,Play Now!
Meal Delivery,LocalIngredients,Locally sourced ingredients
Meal Delivery,VegDietary,Yes, vegetarian
Meal Delivery,KetoDietary,Yes, keto
Meal Delivery,NoDietary,No
Meal Delivery,OtherDietary,Other
Meal Delivery,Nutritional,Nutritional value
Meal Delivery,Taste,Taste
Meal Delivery,Variety,Variety of options
Meal Delivery,Recyclable,Recyclable packaging
Meal Delivery,FlexiSubscription,Flexible subscription
Meal Delivery,ShortCooking,Short cooking time
Meal Delivery,LowPrice,Low prices
Meal Delivery,MD1,1 person
Meal Delivery,MD2,2 people
Meal Delivery,MD3,3 people
Meal Delivery,MD4,4 people
Meal Delivery,MD5more,5 or more
Meal Delivery,MDdiabetic,Diabetic-friendly
Meal Delivery,MDfamily,Family-friendly
Meal Delivery,MDketo,Keto
Meal Delivery,MDkits,Meal kits
Meal Delivery,MDprepared,Pre-cooked meals
Meal Delivery,MDvegan,Vegan
Meal Delivery,MDvegetarian,Vegetarian
Meal Delivery,MDmeatveggies,Meat and veggies
Product Features,Removablecover,Removable cover
Product Features,Machinewashable,Machine washable
Product Features,Ecofriendlymaterials,Eco-friendly materials
Cooking Skill,Nonexistent,Non-existent
Cooking Skill,Notworst,Not the worst!
Cooking Skill,Greatcook,I'm a great cook
Cooking Skill,Prof,I'm practically a professional
Speed Preferences,10minQDS,10 Minutes
Speed Preferences,2hoursQDS,In a few hours
Speed Preferences,NomatterQDS,Does not matter
Bridge Page,Bridge page body text,Attention! This site contains adult photos and videos of women. Please be discreet.
Bridge Page,Bridge page headline zero,Top rated casual dating sites"""

df = pd.read_csv(io.StringIO(csv_data))
summary = df.groupby('CATEGORY').size().reset_index(name='Key Count')
print(summary.to_string(index=False))
/*
*/
/*
EOF-METADATA-BEGIN
HASH: eb467305ae6281c330071eddc8f4cc18b3cb18fb053e08a78b91620d203992d58d86a61e6d62dd2a296699e60a0ecdc1584f932c5b3e41f4173f09b98b78e64a
SIGNATURE: MEQCIAyCkLYuVHMqfXC88dsYMKdtaIGyhsCBQgv+UD+V81mJAiBmHbENjw+V6Tgi7ANl43Xjcsy62kuTYdTEQ5Ng5PD0Ig==
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: cseeesv.py
EOF-METADATA-END
*/
