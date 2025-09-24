# 🎮 Pico Card TCG

A pixel art style Trading Card Game built with Flutter for mobile devices. Features a complete card battle system, collection management, pack opening mechanics, and low-poly pixel aesthetics.

## 🎯 Features

### ✅ Implemented
- **Main Menu** - Clean, pixel-themed navigation
- **Card Collection System** - View and manage your cards by rarity
- **Shop System** - Buy card packs with coins
- **Pack Opening** - Random card generation with rarity-based distribution
- **Battle System** - Turn-based combat mechanics with mana system
- **Player Progression** - Coin economy and collection building
- **Data Persistence** - Save progress using SharedPreferences
- **Card Viewing** - Detailed card inspection with stats and abilities

### 🚧 Planned Features
- **Advanced Deck Builder** - Full deck customization interface
- **Enhanced Battle AI** - Smarter enemy behavior
- **Card Animations** - GIF support for animated cards
- **Additional Cards** - Expanded card library
- **Achievements System** - Unlock rewards for playing
- **Online Multiplayer** - Battle against other players

## 🏗️ Project Structure

```
lib/
├── models/                 # Data models
│   ├── card_model.dart    # GameCard and rarity system
│   └── player_model.dart  # Player and CardPack models
├── services/              # Business logic
│   ├── card_service.dart  # Card loading and pack opening
│   ├── player_service.dart # Player data management
│   └── game_provider.dart # State management
├── screens/               # UI screens
│   ├── shop_screen.dart   # Card pack purchasing
│   ├── collection_screen.dart # Card collection viewer
│   └── battle_screen.dart # Combat interface
├── widgets/               # Reusable components
│   └── card_widget.dart   # Card display component
├── data/cards/            # Card definitions
│   ├── common/           # Common rarity cards
│   ├── rare/             # Rare cards
│   ├── epic/             # Epic cards
│   └── legendary/        # Legendary cards
└── main.dart             # App entry point
```

## 🎴 Card System

### Rarity Distribution
- **Common** (70%): Basic cards for beginners
- **Rare** (25%): More powerful abilities
- **Epic** (4%): Strong tactical options
- **Legendary** (1%): Game-changing effects

### Sample Cards
1. **Pico Warrior** (Common) - 2/2/3 with Charge
2. **Pixel Mage** (Rare) - 3/2/2 with Spell Power and Battlecry
3. **Pico Dragon** (Legendary) - 8/8/8 with Flying, Battlecry, and Deathrattle

## ⚔️ Battle System

- **Turn-based Combat** - Alternate between player and enemy turns
- **Mana System** - Resource management for playing cards
- **Health Points** - Both players start with 20 HP
- **Card Types** - Creatures, Spells, and Artifacts
- **Abilities** - Special effects like Charge, Flying, Battlecry

## 💰 Economy System

- Start with 500 coins
- **Basic Pack**: 100 coins for 5 random cards
- **Premium Pack**: 200 coins for 5 cards with better odds
- Earn coins through battles and achievements (coming soon)

## 🎨 Design Philosophy

**Pixel Art Aesthetic**
- Low-poly, retro-inspired visual style
- 8-bit color palette with modern UI elements
- Clean, readable typography
- Consistent pixel-perfect styling

## 🛠️ Technical Stack

- **Framework**: Flutter 3.32.8
- **Language**: Dart 3.8.1
- **State Management**: Provider pattern
- **Data Persistence**: SharedPreferences
- **JSON Serialization**: json_annotation/json_serializable
- **UI Components**: Material Design with custom styling

## 📱 Getting Started

### Prerequisites
- Flutter SDK (3.0.0+)
- Android Studio / VS Code
- Android device or emulator

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd pico_card

# Install dependencies
flutter pub get

# Generate JSON serialization code
flutter packages pub run build_runner build

# Run the app
flutter run
```

### Running on Android
1. Enable USB debugging on your Android device
2. Connect device via USB
3. Run `flutter devices` to verify connection
4. Execute `flutter run`

## 🎮 How to Play

1. **Start**: Launch the app to see your player stats
2. **Shop**: Buy card packs to build your collection
3. **Collection**: View your cards organized by rarity
4. **Battle**: Fight against AI with your deck
5. **Progress**: Earn coins and expand your collection

## 🔧 Development Notes

### Adding New Cards
1. Create JSON file in appropriate rarity folder
2. Update `CardService._loadAllCards()` to include new card
3. Add card image placeholder to `assets/images/cards/`
4. Run `flutter pub get` to refresh assets

### Database Schema
Player data is stored as JSON in SharedPreferences:
- Player stats (coins, level, experience)
- Card collection (list of card IDs)
- Current deck configuration

## 🚀 Future Enhancements

### Phase 1: Core Improvements
- [ ] Advanced deck builder with drag-drop interface
- [ ] Enhanced battle animations and effects
- [ ] Sound effects and background music
- [ ] More cards across all rarities

### Phase 2: Social Features
- [ ] Online multiplayer battles
- [ ] Leaderboards and rankings
- [ ] Daily quests and rewards
- [ ] Friend system

### Phase 3: Advanced Features
- [ ] Tournament mode
- [ ] Card trading system
- [ ] Seasonal events
- [ ] Premium currency and cosmetics

## 🎨 Asset Requirements

For full visual experience, add these assets:
- Card artwork (PNG): `assets/images/cards/[card_name]_static.png`
- Card animations (GIF): `assets/images/cards/[card_name]_animated.gif`
- Pixel fonts: `assets/fonts/` (optional)
- UI icons and backgrounds

## 📄 License

This project is for educational and demonstration purposes.

## 🤝 Contributing

This is a demo project, but feel free to fork and enhance it with your own features!

---

**Built with ❤️ using Flutter for the pixel art TCG community**
