//
//  InventoryViewController.h
//  UICollectionView-Spring-Demo
//
//  Created by Alexander Stone on 12/18/13.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"
#import "OBDragDrop.h"
#import "CharacterSelectionBaseViewController.h"




@class Item;
@class CharacterBase;
@class ItemImageView;



@interface InventoryViewController : CharacterSelectionBaseViewController<UICollectionViewDataSource,UICollectionViewDelegate,OBOvumSource, OBDropZone,ItemUpgradeSwapDelegate,UIAlertViewDelegate,CharacterSelectionDelegate>





@property(nonatomic,strong)NSArray* inventoryBag;
@property(nonatomic,strong)Item* selectedItem;

@property (strong, nonatomic) IBOutlet ItemImageView *inventoryDollImageView;
@property (strong, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *itemImageView;

@property (strong, nonatomic) IBOutlet UICollectionView *inventoryBagCollectionView;

@property (strong, nonatomic) IBOutlet UICollectionView *ringsCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *potionsCollectionView;

- (IBAction)equipButton:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *inventoryDoll;
@property (strong, nonatomic) IBOutlet ItemImageView *weapon;
@property (strong, nonatomic) IBOutlet ItemImageView *amulet;
@property (strong, nonatomic) IBOutlet ItemImageView *cloak;
@property (strong, nonatomic) IBOutlet ItemImageView *shieldImageView;
@property (strong, nonatomic) IBOutlet ItemImageView *helmet;
@property (strong, nonatomic) IBOutlet ItemImageView *boots;
@property (strong, nonatomic) IBOutlet ItemImageView *armor;
@property (strong, nonatomic) IBOutlet ItemImageView *secondaryWeapon;


@property (strong, nonatomic) IBOutlet UIButton *sellButton;


@property (strong, nonatomic) IBOutlet UILabel *salePriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *upgradePriceLabel;
@property (strong, nonatomic) IBOutlet UIButton *upgradeButton;



- (IBAction)sellAction:(id)sender;
- (IBAction)upgradeAction:(id)sender;

- (IBAction)healthPotionAction:(id)sender;
- (IBAction)staminaPotionAction:(id)sender;



@property (strong, nonatomic) IBOutlet UIButton *staminaPotionButton;

@property (strong, nonatomic) IBOutlet UIButton *healthPotionButton;

@property (strong, nonatomic) IBOutlet UIButton *resurrectButton;
@property (strong, nonatomic) IBOutlet UILabel *staminaPotionLabel;
@property (strong, nonatomic) IBOutlet UILabel *staminaPotionPriceLabel;

@property (strong, nonatomic) IBOutlet UILabel *healthPotionLabel;
@property (strong, nonatomic) IBOutlet UILabel *healthPotionPriceLabel;

@property (strong, nonatomic) IBOutlet UIView *item2Container;
@property (strong, nonatomic) IBOutlet UIView *item1Container;

@property(nonatomic,strong)NSMutableDictionary* imageCache;


@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *buttonImitationUpgradeViews;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *buttonImitationSaleViews;

@property (strong, nonatomic) IBOutlet UIImageView *sellImageView;

@property (strong, nonatomic) IBOutlet UIImageView *upgradeImageView;

-(void)prepareForDeletion;

@end
