//
//  InventoryViewController.m
//  UICollectionView-Spring-Demo
//
//  Created by Alexander Stone on 12/18/13.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "InventoryViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "CharacterModelNode.h"
#import "CharacterBase.h"

#import "EquipmentGenerator.h"

#import "InventoryBagCell.h"
#import "RingsCell.h"
#import "ItemStatsCell.h"
#import "ItemSpecsCell.h"
#import "PotionCell.h"




#import "Armor.h"
#import "Weapon.h"
#import "BuffAction.h"
#import "Ring.h"
#import "Amulet.h"

#import "BuffCollection.h"


#import "GameDataManager.h"

#import "ItemImageView.h"
#import "InventoryDoll.h"
#import "UpgradeViewController.h"
#import "childViewController.h"

#import "ItemStatsViewController.h"


@interface InventoryViewController ()
{
    ItemStatsViewController* item1;
    ItemStatsViewController* item2;
    ItemStatsViewController* item3;
    
    NSMutableDictionary* workingItemDictionary;
    UpgradeViewController* upgradeViewController;
    BOOL needReequipItem;
    
    int pendingPotionAction;
    
    NSArray* ringsArray;
    UIColor* inventoryBorderColor;
    
    BOOL preventDuplicateDrop;//a workaround for ovum dropped on the inventory bag really quickly
    
    InventoryBagCell* selectedCell;
}
@end


@implementation InventoryViewController

static NSString * kRingCell = @"ringCell";
static NSString * kBagCell = @"bagCell";
static NSString * kStatsCell = @"statsCell";
static NSString * kSpecsCell = @"specsCell";
static NSString * kPotionCell = @"potionCell";

-(void)viewDidLoad {
    [super viewDidLoad];
    
    inventoryBorderColor =[UIColor lightGrayColor];
    
    //create inventory overlay
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Storyboard"
                                                             bundle: nil];

    

 
    [self setupGestureRecognizers];
    
    [ViewStyle roundCorners:self.armor];
    [ViewStyle roundCorners:self.shieldImageView];
    [ViewStyle roundCorners:self.helmet];
    [ViewStyle roundCorners:self.boots];
    [ViewStyle roundCorners:self.cloak];
    
    
    [ViewStyle roundCorners:self.secondaryWeapon];
    [ViewStyle roundCorners:self.weapon];
    
    [ViewStyle roundCorners:self.itemImageView];
    
    [ViewStyle roundCorners:self.sellButton];
    [ViewStyle roundCorners:self.upgradeButton];
    
    [ViewStyle roundCorners:self.closeButton];
    
    item1 = (ItemStatsViewController*)[mainStoryboard  instantiateViewControllerWithIdentifier: @"itemStatsViewController"];
    item2 = (ItemStatsViewController*)[mainStoryboard  instantiateViewControllerWithIdentifier: @"itemStatsViewController"];
    item3 = (ItemStatsViewController*)[mainStoryboard  instantiateViewControllerWithIdentifier: @"itemStatsViewController"];
    

    [self addChildViewController:item1];
    [self addChildViewController:item2];
    [self addChildViewController:item3];
    
    item1.view.frame=self.item1Container.bounds;
    item2.view.frame=self.item2Container.bounds;
    
    [self.item1Container addSubview:item1.view];
    [self.item2Container addSubview:item2.view];
    
    item1.titleLabel.text = @"Item 1";
    item2.titleLabel.text = @"Item 2";
    item3.titleLabel.text = @"Item 3";
    
    item1.imageCacheDictinary = self.imageCache;
    item2.imageCacheDictinary = self.imageCache;
    item3.imageCacheDictinary = self.imageCache;
    
    [item1 didMoveToParentViewController:self];
    [item2 didMoveToParentViewController:self];
    
    [ViewStyle style:self.sellButton];
    [ViewStyle style:self.upgradeButton];
    

//    self.sellImageView.image = [UIImage imageNamed:@"scales.png"];
//    self.upgradeImageView.image = [UIImage imageNamed:@"anvil.png"];
}


#pragma mark -
#pragma mark Collection View

-(NSArray*)equipmentForSelectedCharacter
{
    NSPredicate *p = nil;
    
    switch (self.selectedCharacter.type) {
        case kWarrior:
            
            
            //all armor, allweapons
//            proficiencyType<=4 //weapon
//            type <= 3 //armor type
            p = [NSPredicate predicateWithFormat:@"proficiencyType <= %i OR type <= %i",
                 kWeaponProficiencyMartial,
                 kArmorHeavy];
            break;
            
        case kPriest:
//            tupe <=2
//            proficiencyType<=3
             p = [NSPredicate predicateWithFormat:@"proficiencyType <= %i OR type <= %i",
                  kWeaponProficiencyMedium,
                  kArmorMedium];
            break;
            
        case kRogue:
//            type <=1
//            proficiencyType<=2
            p = [NSPredicate predicateWithFormat:@"proficiencyType <= %i OR type <= %i",
                 kWeaponProficiencyLight,
                 kArmorLight];
            break;
            
        case kWizard:
             p = [NSPredicate predicateWithFormat:@"proficiencyType == %i OR proficiencyType == %i OR type == %i ",
                  kWeaponProficiencyCommon,
                  kWeaponProficiencyMagic,
                  kArmorCloth];
//            type == 0
//            proficiencyType<=1
            break;
            
        case kDruid:
//            type<=1
//            proficiencyType<=1 || 6
            p = [NSPredicate predicateWithFormat:@"proficiencyType == %i OR proficiencyType == %i OR type == %i ",
                 kWeaponProficiencyCommon,
                 kWeaponProficiencyMagic,
                 kArmorCloth];

            break;
            
        case kRanger:
//            type <=2
//            proficiencyType<=2 || 5
            p = [NSPredicate predicateWithFormat:@"proficiencyType == %i OR proficiencyType == %i OR type <= %i ",
                 kWeaponProficiencyLight,
                 kWeaponProficiencyMartialRanged,
                 kArmorLight];

            break;
            
        default:
            break;
    }
    NSArray* sharedInventory = [[GameDataManager sharedInstance]partyInventory];
    NSArray* filteredInventory  = [sharedInventory filteredArrayUsingPredicate:p];

    return filteredInventory;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if([collectionView isEqual:self.statCollectionView])
    {
        return 11;
    }
    else if([collectionView isEqual:self.inventoryBagCollectionView])
    {
        
        
        self.inventoryBag = [self equipmentForSelectedCharacter];

        
        
        return self.inventoryBag.count;
        
        
        
        
    }else if ([collectionView isEqual:self.ringsCollectionView])
    {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"index == %i OR index == %i", xAmulet,xRing];
        ringsArray = [self.selectedCharacter.equipment filteredArrayUsingPredicate:p];
        return 10;
//        return ringsArray.count;

    }
    else if ([collectionView isEqual:self.potionsCollectionView])
    {
        if(self.selectedCharacter.isDead)
        {
            //only show the ressurect potion
            return 1;
        }else
        {
            return 5;
        }
    }
    return 0;
}


enum ArmorAttributes {
    kAttributeArmor,
    kAttributeResist,
    kAttributeHPBonus,
    kAttributeMovePenalty,
    kAttributeAttackPenalty,
    kAttributeCounterPenalty
    
};
enum WeaponAttributes {
    kWeaponAttributeHands,
    kWeaponAttributeDamage,
    kWeaponAttributeCounter,
    kWeaponAttributeStaminaDamage,
    kWeaponAttributeArmorPenetration,
    kWeaponAttributeArmorBonus,
    kWeaponAttributeReach
};

-(void)configureCell:(ItemStatsCell*)cell withKey:(NSString*)key
{
    int value = [[workingItemDictionary objectForKey:key] intValue];
    NSString* modifier = @"";
    if([key containsString:@"Penalty"])
    {
        modifier = @"-";
    }
    cell.imageView.image = [self.imageCacheDictinary objectForKey:key];
    cell.label.text = [NSString stringWithFormat:@"%@%i",modifier,value];

    
    [workingItemDictionary removeObjectForKey:key];
    
}

-(void)configureCell:(ItemStatsCell*)cell withAttributeType:(int)type
{
    if([self.selectedItem isKindOfClass:[Armor class]])
    {
        Armor* armor = (Armor*)self.selectedItem;
        switch (type) {
            case kAttributeArmor:
            {
                switch (armor.type) {
                    case kArmorCloth:
                        
                        break;
                    case kArmorLight:
                        cell.imageView.image = self.lightArmor;
                        cell.label.text = [NSString stringWithFormat:@"%i",armor.armor];
                        break;
                    case kArmorMedium:
                        cell.imageView.image = self.mediumArmor;
                        cell.label.text = [NSString stringWithFormat:@"%i",armor.armor];
                        break;
                    case kArmorHeavy:
                        cell.imageView.image = self.heavyArmor;
                        cell.label.text = [NSString stringWithFormat:@"%i",armor.armor];
                        break;
                        
                        
                    default:
                        break;
                }
                
            }
                break;
                
            case kAttributeResist:
            {
                cell.imageView.image = self.magicResist;
                cell.label.text = [NSString stringWithFormat:@"%i",armor.resist];
                
                break;
            }
                
            case kAttributeHPBonus:
            {
                
                cell.imageView.image = self.health;
                cell.label.text = [NSString stringWithFormat:@"%i",armor.hpBonus];
                
            }
                break;
                
            case kAttributeMovePenalty:
            {
                cell.imageView.image = self.foot;
                cell.label.text = [NSString stringWithFormat:@"-%i",armor.movePenalty];
            }
                break;
                
            case kAttributeAttackPenalty:
                
                cell.imageView.image = self.sword;
                cell.label.text = [NSString stringWithFormat:@"-%i",armor.attackPenalty];
                break;
                
            case kAttributeCounterPenalty:
                cell.imageView.image = self.counterattack;
                cell.label.text = [NSString stringWithFormat:@"-%i",armor.counterPenalty];
                break;
                
            default:
                break;
        }
    }
    
    
    
    
    if([self.selectedItem isKindOfClass:[Weapon class]])
    {
        Weapon* weapon = (Weapon*)self.selectedItem;
        switch (type) {
            case kWeaponAttributeDamage:
            {
                if(self.selectedItem.index < 100)
                {
                    //melee
                    cell.imageView.image = self.sword;
                    cell.label.text = [NSString stringWithFormat:@"%i",weapon.meleeDamage];
                    [workingItemDictionary removeObjectForKey:@"meleeDamage"];
                }else if(self.selectedItem.index < 300)
                {
                    //bow
                    cell.imageView.image = self.bow;
                    cell.label.text = [NSString stringWithFormat:@"%i",weapon.rangedDamage];
                    [workingItemDictionary removeObjectForKey:@"rangedDamage"];
                }else if(self.selectedItem.index >= 300)
                {
                    //magic
                    cell.imageView.image = self.magic;
                    cell.label.text = [NSString stringWithFormat:@"%i",weapon.magicDamage];
                    [workingItemDictionary removeObjectForKey:@"magicDamage"];
                }
                
                break;
            }
            case kWeaponAttributeCounter:
            {

                if(self.selectedItem.index < 100)
                {
                    //melee
                    cell.imageView.image = self.counterattack;
                }else if(self.selectedItem.index < 300)
                {
                    //bow
                    cell.imageView.image = self.rangedCounterattack;
                }else if(self.selectedItem.index >= 300)
                {
                    //magic
                    cell.imageView.image = self.magicCounterattack;
                }

                cell.label.text = [NSString stringWithFormat:@"%i",weapon.counterAttack];
                break;
            }
            case kWeaponAttributeHands:
            {
                cell.imageView.image = self.hands;
                cell.label.text = [NSString stringWithFormat:@"%i",weapon.hands];
                break;
            }
            case kWeaponAttributeStaminaDamage:
            {
                cell.imageView.image = self.staminaDamage;
                cell.label.text = [NSString stringWithFormat:@"%i",weapon.staminaDamage];
                break;
            }
            case kWeaponAttributeArmorPenetration:
            {
                cell.imageView.image = self.armorPenetration;
                cell.label.text = [NSString stringWithFormat:@"%i",weapon.armorPenetration];
                break;
            }case kWeaponAttributeArmorBonus:
            {
                cell.imageView.image = self.heavyArmor;
                cell.label.text = [NSString stringWithFormat:@"%i",weapon.armorBonus];
                break;
            }case kWeaponAttributeReach:
            {
                cell.imageView.image = self.reach;
                cell.label.text = [NSString stringWithFormat:@"%i",weapon.reach];
                break;
            }
       
        }
    }
    
    
    
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    

    if([collectionView isEqual:self.potionsCollectionView])
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPotionCell forIndexPath:indexPath];
        [ViewStyle style:cell];
        
        PotionCell* potionCell = (PotionCell*)cell;
        {
            
            potionCell.costLabel.text = @"- 100";
            
            switch (indexPath.row) {
                case kPotionHealing:
                    
                    if(self.selectedCharacter.isDead)
                    {
                        potionCell.potionName.text = @"Drink  Resurrect Potion";
                        potionCell.effectImage.image = [UIImage imageNamed:@"healthPotion.png"];
                        potionCell.effectLabel.text = @"+50%";
                        potionCell.costLabel.text = @"- 500";
                    }else
                    {
                        potionCell.potionName.text = @"Drink Health Potion";
                        potionCell.effectImage.image = [UIImage imageNamed:@"healthPotion.png"];
                        potionCell.effectLabel.text = [NSString stringWithFormat:@"+%i",[self healthPotionValue]];
                    }
                    
                    
                    
                    break;
                    
                case kPotionStamina:
                    potionCell.potionName.text = @"Drink Stamina Potion";
                    potionCell.effectImage.image = [UIImage imageNamed:@"staminaPotion.png"];
                    potionCell.effectLabel.text = [NSString stringWithFormat:@"+%i",[self staminaPotionValue]];
                    break;
                    
                case kPotionPoisonCure:
                    potionCell.potionName.text = @"Drink Cure Poison";
                    potionCell.effectImage.image = [UIImage imageNamed:@"curePoison.png"];
                    potionCell.effectLabel.text = @"- 6";
                    break;
                    
                case kRagePotion:
                    potionCell.potionName.text = @"Eat Rage Shroom";
                    potionCell.effectImage.image = [UIImage imageNamed:@"rageMushroom.png"];
                    potionCell.effectLabel.text = @"+5";
                    break;
                    
                case kPotionPower:
                    potionCell.potionName.text = @"Drink Magic Power";
                    potionCell.effectImage.image = [UIImage imageNamed:@"powerPotion.png"];
                    potionCell.effectLabel.text = @"+4";
                    break;
                    
                default:
                    break;
            }
        }
        
        
    }
    else if([collectionView isEqual:self.inventoryBagCollectionView])
    {
        
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBagCell forIndexPath:indexPath];
        InventoryBagCell* bagCell = (InventoryBagCell*)cell;
        bagCell.item = self.inventoryBag[indexPath.row];
        
        [bagCell configureWithDragDropParent:self];
    
    }else if ([collectionView isEqual:self.ringsCollectionView])
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRingCell forIndexPath:indexPath];
        
        RingsCell* ringCell = (RingsCell*)cell;
        [ringCell configureWithDragDropParent:self];
        
        if(indexPath.row<ringsArray.count)
        {
            
            ringCell.item = ringsArray[indexPath.row];
        }else
        {
            ringCell.Item = nil;
        }
        
    }
    return cell;
}



- (IBAction)backgroundButtonDebug:(id)sender {
    
    
    UIButton* button =((UIButton*)sender);
    DLog(@"Tapped background button with dimensions: x%.0f, y%.0f w%.0f h%.0f",button.frame.origin.x, button.frame.origin.y, button.frame.size.width,button.frame.size.height);
    
}

#pragma mark -
#pragma mark ACTIONS


- (IBAction)sellAction:(id)sender {

    if(self.selectedItem == nil)
    {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        for(UIView* v in self.buttonImitationSaleViews)
        {
            v.alpha = 0.4;
        }
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 animations:^{
            for(UIView* v in self.buttonImitationSaleViews)
            {
                v.alpha = 1;
            }
        }];
    }];
    
    
    int index = [self.inventoryBag indexOfObject:self.selectedItem];

    DLog(@"Selling: %@", [self.selectedItem description]);
    
    if([self.selectedCharacter hasItemEquipped:self.selectedItem])
    {
//        [self.selectedCharacter unEquipItem:self.selectedItem];
        [self.selectedCharacter addRemove:self.selectedItem add:NO];
        [self updateDollWithItem:nil slot:self.selectedItem.imageView];
        
    
        if([self.selectedItem isKindOfClass:[Weapon class]])
        {
            Weapon* weapon = (Weapon*)self.selectedItem;
            if(weapon.hands ==2)
            {
                self.shieldImageView.item = nil;
                
            }
            [self updateDollWithItem:self.selectedCharacter.weaponSlot];
            [self updateDollWithItem:self.selectedCharacter.secondaryWeapon];
        }
        [self.selectedCharacter resetCache];
    }else if([self.selectedItem isEqual:self.selectedCharacter.secondaryWeapon])
    {
        [self.selectedCharacter addRemove:self.selectedItem add:NO];
        [self updateDollWithItem:nil slot:self.selectedItem.imageView];
        [self.selectedCharacter resetCache];
    }
    
    
    
    [[[GameDataManager sharedInstance] partyInventory]removeObject:self.selectedItem];
    int salePrice = self.selectedItem.price*0.2;
    
    self.selectedItem = nil;
    [[GameDataManager sharedInstance] increaseGoldCountBy:salePrice];
    
    //refresh to indicate update
    [self.inventoryBagCollectionView reloadData];
    
    if([item1.selectedItem isEqual:self.selectedItem])
    {
        item1.selectedItem = nil;
    }
    
    if([item2.selectedItem isEqual:self.selectedItem])
    {
        item2.selectedItem = nil;
    }
    
    if([item3.selectedItem isEqual:self.selectedItem])
    {
        item3.selectedItem = nil;
    }
    
    [item1 refresh];
    [item2 refresh];
    [item3 refresh];
    self.itemImageView.image = nil;
    
    [self refreshSelectedCharacterStats];
    
    //select first item
    if(self.inventoryBag.count>0)
    {
        
        if(index + 1<self.inventoryBag.count)
        {
           self.selectedItem = self.inventoryBag[index+1];
        }else{
           self.selectedItem = self.inventoryBag[0];
        }
        
    }
}


-(void)character:(CharacterBase*)character willUpgradeItem:(Item*)item
{
    if([character hasItemEquipped:item])
    {
        [character addRemove:item add:NO];
        needReequipItem = YES;
    }
}
-(void)character:(CharacterBase*)character didUpgradeItem:(Item*)item
{
    if(needReequipItem)
    {

        [character addRemove:item add:YES];

    }
    
    if([self.inventoryBag indexOfObject:item] != NSNotFound)
    {
        [self.inventoryBagCollectionView reloadData];
    }
    
    needReequipItem = NO;
    
    
    [self closeButtonAction:upgradeViewController];

}
- (IBAction)upgradeAction:(id)sender {
    DLog(@"Upgrade");
    
    if(self.selectedItem!= nil && self.selectedItem.upgradeType == kUpgradeNone)
    {
        

        
        if(upgradeViewController == nil)
        {
        //create inventory overlay
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Storyboard"
                                                                 bundle: nil];
        upgradeViewController = (UpgradeViewController*)[mainStoryboard
                                                                  instantiateViewControllerWithIdentifier: @"UpgradeViewController"];
        
        upgradeViewController.view.frame = CGRectMake(self.view.bounds.size.width-400, 0, 400, 450);
        upgradeViewController.parentViewController = self;
            [ViewStyle thickStyle: upgradeViewController.view];
            
            
        }
        
        upgradeViewController.delegate = self;
        upgradeViewController.character = self.selectedCharacter;
        upgradeViewController.item = self.selectedItem;
        upgradeViewController.view.alpha = 0;
        [self.view addSubview:upgradeViewController.view];
        
        //dim contents of the upgrade view in response to touch to imitate button
        [UIView animateWithDuration:0.5 animations:^{
            for(UIView* v in self.buttonImitationUpgradeViews)
            {
                v.alpha = 0.4;
                 upgradeViewController.view.alpha = 1;
            }
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                for(UIView* v in self.buttonImitationUpgradeViews)
                {
                    v.alpha = 1;
                }
            }];
        }];
        
    }
}


- (IBAction)healthPotionAction:(id)sender {
    DLog(@"Health Potion");
    
    if(self.selectedCharacter == nil)
    {
        return;
    }else
    {
        if([[GameDataManager sharedInstance] currentEnergyCount]>100)
        {
            [[GameDataManager sharedInstance] increaseEnergyCountBy:-100];
            self.selectedCharacter.currentHP = fmin(self.selectedCharacter.hp, self.selectedCharacter.currentHP+ self.selectedCharacter.hp * 0.25);

        }
    }
}

- (IBAction)staminaPotionAction:(id)sender {
    DLog(@"Stamina Potion");
    
    if(self.selectedCharacter == nil)
    {
        return;
    }else
    {
        if([[GameDataManager sharedInstance] currentEnergyCount]>100)
        {
            [[GameDataManager sharedInstance] increaseEnergyCountBy:-100];
            self.selectedCharacter.currentSP = fmin(self.selectedCharacter.sp, self.selectedCharacter.currentSP+ self.selectedCharacter.sp * 0.25);
            
        }
    }
}


-(void)cleanupBeforeClose
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [upgradeViewController.view removeFromSuperview];

}

- (IBAction)closeButtonAction:(id)sender {
    
    if([sender isKindOfClass:[UpgradeViewController class]])
    {
        [upgradeViewController.view removeFromSuperview];
        
        self.itemNameLabel.text = [_selectedItem descriptiveName];
        [item1 refresh];
        
        if(self.selectedItem.upgradeType != kUpgradeNone)
        {
            self.upgradePriceLabel.text = @"---";
        }
        [self refreshSelectedCharacterStats];
        
    }
    
}

#pragma mark -
#pragma mark SELECTION

-(void)didSelectPartyMember:(CharacterBase*)character
{
    self.selectedCharacter  = character;
    self.selectedItem = nil;
    
    if(self.selectedCharacter.isDead)
    {
        [UIView animateWithDuration:0.4 animations:^{
            self.staminaPotionButton.alpha = 0;
            self.healthPotionButton.alpha = 0;
            self.staminaPotionLabel.alpha = 0;
            self.staminaPotionPriceLabel.alpha = 0;
        } completion:^(BOOL finished) {
            self.healthPotionLabel.text = @"Resurrect";
            self.healthPotionPriceLabel.text = @"500";
            
            [UIView animateWithDuration:0.3 animations:^{
                self.resurrectButton.alpha = 1;
                
            }];
            
        }];
        
    }else
    {
        {
            [UIView animateWithDuration:0.4 animations:^{
                
                self.resurrectButton.alpha = 0;
                self.healthPotionLabel.text = @"Healing 33% hp";
                self.healthPotionPriceLabel.text = @"100";
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.staminaPotionButton.alpha = 1;
                    self.healthPotionButton.alpha = 1;
                    self.staminaPotionLabel.alpha = 1;
                    self.staminaPotionPriceLabel.alpha = 1;
                }];
                
            }];
            
        }
    }
    

    
    self.inventoryDollImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_inventory.png",self.selectedCharacter.name]];
    //do shield first, otherwise it clears 2nd hand graphic for 2h weapon
   
    [self updateDollWithItem:self.selectedCharacter.weaponSlot slot:self.weapon];
    [self updateDollWithItem:self.selectedCharacter.secondaryWeapon slot:self.secondaryWeapon];
    [self updateDollWithItem:self.selectedCharacter.shieldSlot slot:self.shieldImageView];
    
    [self updateDollWithItem:self.selectedCharacter.bodySlot slot:self.armor];
    [self updateDollWithItem:self.selectedCharacter.bootsSlot slot:self.boots];
    [self updateDollWithItem:self.selectedCharacter.cloakSlot slot:self.cloak];
    [self updateDollWithItem:self.selectedCharacter.amuletSlot slot:self.amulet ];
    [self updateDollWithItem:self.selectedCharacter.headSlot slot:self.helmet];
    
    
    
    item1.selectedItem = self.selectedCharacter.weaponSlot;
    item2.selectedItem = self.selectedCharacter.secondaryWeapon;
    [self.potionsCollectionView reloadData];
    [self.ringsCollectionView reloadData];
    
    [self.inventoryBagCollectionView reloadData];
    
}

-(void)selectPartyMemberWithIndex:(int)index
{
    
}



#pragma mark -
#pragma mark UPDATING DOLL

-(void)updateDollWithItem:(Item*)item
{
    if(item==nil)
    {
        return;
    }
    
    ItemImageView* slot = nil;
if([item isKindOfClass:[Armor class]])
    {
        Armor* armor = (Armor*)item;
        switch (armor.slot) {
            case kArmorSlotBody:
            {
                slot = self.armor;
                break;
            }
            case kArmorSlotCloak:
            {
                slot = self.cloak;
                break;
            }
            case kArmorSlotFeet:
            {
                slot = self.boots;
                break;
            }
            case kArmorSlotHead:
            {
                slot = self.helmet;
                break;
            }
            
            case kArmorSlotRing:
            case kArmorSlotAmulet:
            {
                [self.ringsCollectionView reloadData];
                break;
            }case kArmorSlotShield:
            {
                slot = self.shieldImageView;
                break;
            }
            default:
            {
                NSAssert(false, @"armor type not supported");
                break;
            }
                
        }
    }else if([item isKindOfClass:[Weapon class]])
    {
        slot = self.weapon;
        Weapon* weapon = (Weapon*)item;
        
        self.secondaryWeapon.item = self.selectedCharacter.secondaryWeapon;
        //special case for 2 handed weapon - we want to automatically unequip shield and replace it's image by the copy of 2 handed weapon.
        if(weapon.hands==2)
        {
            self.shieldImageView.image = weapon.image;
            self.shieldImageView.alpha = 0.5;
        }else
        {
            //check if we don't have a shield, and replace the possible 2h graphic of weapon with a blank space to indicate no shield
            if(self.selectedCharacter.shieldSlot==nil)
            {
                self.shieldImageView.image = nil;
                self.shieldImageView.alpha = 1.0;
            }else
            {
                //has shield
                self.shieldImageView.image = self.selectedCharacter.shieldSlot.image;
                self.shieldImageView.alpha = 1.0;
            }

        }
        
    }
    

        if(self.selectedItem == nil)
        {
            self.selectedItem = item;
        }if(item2.selectedItem == nil)
        {
            //initial loading
            item2.selectedItem = self.selectedCharacter.secondaryWeapon;
        }
    slot.item = item;
    [self.statCollectionView reloadData];

}
-(void)updateDollWithItem:(Item*)item slot:(ItemImageView*)slot
{
    if(item!=nil)
    {
        if([item isKindOfClass:[Weapon class]])
        {
            
            Weapon* weapon = (Weapon*)item;

            //special case for 2 handed weapon - we want to automatically unequip shield and replace it's image by the copy of 2 handed weapon.
            if([weapon isEqual:self.selectedCharacter.secondaryWeapon])
            {
                
            }
            else if(weapon.hands==2)
            {

                self.shieldImageView.image = weapon.image;
                self.shieldImageView.alpha = 0.5;
                
            }else
            {

                self.shieldImageView.alpha = 1.0;
                if(self.selectedCharacter.shieldSlot==nil)
                {
                    self.shieldImageView.image = nil;
                }else
                {
                    //has shield
                    self.shieldImageView.image = self.selectedCharacter.shieldSlot.image;
                }
            }

        }else if ([item isEqual:self.selectedCharacter.shieldSlot])
        {
            self.shieldImageView.alpha = 1.0;
        }
            slot.image = item.image;
            slot.item = item;
        
        if(self.selectedItem == nil)
        {
            self.selectedItem = item;
        }
        
    }else
    {
        slot.image = nil;
        slot.item = nil;
    }
}
//-(void)updateDollWithItem:(Item*)item button:(UIButton*)slot
//{
//    if(item!=nil)
//    {
//        [slot setImage:item.image forState:UIControlStateNormal];
//        
//    }else
//    {
//        slot.imageView.image = nil;
//    }
//}



- (IBAction)equipButton:(id)sender {
    
    if(self.selectedItem == nil || self.selectedCharacter == nil ||self.selectedCharacter.isDead == YES )
    {
        return;
    }
    
    DLog(@"Equip");
   
    [self updateDollWithItem:self.selectedItem];

#warning Need to make sure we properly remove it from it's owner upon this action
    
    //remove the item from the inventory, then show the item we are replacing at slot 1
    [[[GameDataManager sharedInstance] partyInventory] removeObject:self.selectedItem];
    Item* oldItem = [self.selectedCharacter addRemove:self.selectedItem add:YES];
    
    
    if(oldItem!=nil)
    {
        [[[GameDataManager sharedInstance] partyInventory] insertObject:oldItem atIndex:0];
    }
   
    [self refreshInventory];
    [self refreshSelectedCharacterStats];
    
}

-(void)refreshInventory
{

    [item1 refresh];
    [item2 refresh];
    [item3 refresh];
    [self.inventoryBagCollectionView reloadData];
}




-(void)setSelectedItem:(Item *)selectedItem
{
//    item3.selectedItem = selectedItem;
    if(![_selectedItem isEqual:selectedItem])
    {
        item2.selectedItem = _selectedItem;
        item1.selectedItem  = selectedItem;
    }else
    {
        return;
    }
//    [self swapViewControllers];
    
    _selectedItem = selectedItem;
    
    self.itemImageView.image = _selectedItem.image;
    self.itemNameLabel.text = [_selectedItem descriptiveName];
    self.itemImageView.image =  _selectedItem.image;
    self.salePriceLabel.text = [NSString stringWithFormat:@"%.0f",_selectedItem.price*0.2];
    
    if(selectedItem.upgradeType!=kUpgradeNone)
    {
        //already upgraded
        self.upgradePriceLabel.text = [NSString stringWithFormat:@"---"];
    }else
    {
        self.upgradePriceLabel.text = [NSString stringWithFormat:@"%.0f+",_selectedItem.price*0.1];
    }
}
-(void)prepareToAppear
{
    [super prepareToAppear];
    
    self.inventoryBag = [[GameDataManager sharedInstance]partyInventory];

    self.salePriceLabel.text = @"";
    self.upgradePriceLabel.text = @"";
    self.itemImageView.image = nil;
    

    
    self.inventoryBag = [[GameDataManager sharedInstance] partyInventory];
    
    [self.ringsCollectionView reloadData];
    [self.inventoryBagCollectionView reloadData];
    [item1 refresh];
    [item2 refresh];
    [item3 refresh];
}



#pragma mark - OBOvumSource

-(OBOvum *) createOvumFromView:(UIView*)sourceView
{
    if([sourceView isKindOfClass:[ItemImageView class]])
    {
        
        ItemImageView* imageView = (ItemImageView*)sourceView;
        if(imageView.item==nil)
        {
            return nil;
        }
        
        OBOvum *ovum = [[OBOvum alloc] init];
        
        ovum.dataObject = imageView;
        return ovum;
    }else if ([sourceView isKindOfClass:[ItemAbstractBaseCell class]])
    {
        //inventory or rings
        ItemAbstractBaseCell* bagCell = (ItemAbstractBaseCell*)sourceView;
        if(bagCell.item==nil)
        {
            return nil;
        }
        
        OBOvum *ovum = [[OBOvum alloc] init];
        ovum.dataObject = sourceView;
        return ovum;
        
    }
    
    return nil;
}


-(UIView *) createDragRepresentationOfSourceView:(ItemImageView *)sourceView inWindow:(UIWindow*)window
{
    
    ItemImageView* imageView = nil;
    if([sourceView isKindOfClass:[ItemImageView class]])
    {
        imageView = sourceView;
    }else if([sourceView isKindOfClass:[ItemAbstractBaseCell class]])
    {
        ItemAbstractBaseCell* cell = (ItemAbstractBaseCell*)sourceView;
        imageView = cell.imageView;
    }else
    {
        return nil;
    }
    
    CGRect frame = [imageView convertRect:imageView.bounds toView:imageView.window];
    frame = [window convertRect:frame fromWindow:imageView.window];
    
    UIImageView *dragView = [[UIImageView alloc] initWithFrame:frame];
    dragView.image = imageView.image;
    dragView.backgroundColor = imageView.backgroundColor;
    dragView.layer.cornerRadius = 5.0;
    dragView.layer.borderColor = [UIColor cyanColor].CGColor;
    dragView.layer.borderWidth = 2.0;
    dragView.layer.masksToBounds = YES;
    return dragView;
}


-(void) dragViewWillAppear:(UIView *)dragView inWindow:(UIWindow*)window atLocation:(CGPoint)location
{
    dragView.transform = CGAffineTransformIdentity;
    dragView.alpha = 0.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        dragView.center = location;
        dragView.transform = CGAffineTransformMakeScale(0.80, 0.80);
        dragView.alpha = 0.75;
    }];
}



#pragma mark - OBDropZone

static NSInteger kLabelTag = 2323;

-(OBDropAction) ovumEntered:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
//    NSLog(@"Ovum<0x%x> %@ Entered", (int)ovum, ovum.dataObject);
    
//    CGFloat red = 0.33 + 0.66 * location.y / self.view.frame.size.height;
//    view.layer.borderColor = [UIColor colorWithRed:red green:0.0 blue:0.0 alpha:1.0].CGColor;
//    view.layer.borderWidth = 5.0;
    
//    CGRect labelFrame = CGRectMake(ovum.dragView.bounds.origin.x, ovum.dragView.bounds.origin.y, ovum.dragView.bounds.size.width, ovum.dragView.bounds.size.height / 2);
//    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
//    label.text = @"Ovum entered";
//    label.tag = kLabelTag;
//    label.backgroundColor = [UIColor clearColor];
//    label.opaque = NO;
//    label.font = [UIFont boldSystemFontOfSize:24.0];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor whiteColor];
//    [ovum.dragView addSubview:label];
    
    return OBDropActionMove;
}

-(OBDropAction) ovumMoved:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
//NSLog(@"Ovum<0x%x> %@ Moved", (int)ovum, ovum.dataObject);
    
//    CGFloat hiphopopotamus = 0.33 + 0.66 * location.y / self.view.frame.size.height;
    
    if ([ovum.dataObject isKindOfClass:[RingsCell class]] && [view isKindOfClass:[InventoryDoll class]] )
    {
        //do not highlight the rings container or the doll (rings container is not marked as a drop zone)
        return OBDropActionNone;
    }
    else if ([ovum.dataObject isKindOfClass:[InventoryBagCell class]] && [view isKindOfClass:[UICollectionView class]])
    {
        //do not highlight the container where we dragged from
        return OBDropActionNone;
    }else if ([ovum.dataObject isKindOfClass:[ItemImageView class]] && [view isKindOfClass:[InventoryDoll class]])
    {
        return OBDropActionNone;
    }
    
    view.layer.borderColor = [UIColor colorWithRed:0.0 green:0.66 blue:0.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 5.0;
    return OBDropActionMove;
}

-(void) ovumExited:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
//    NSLog(@"Ovum<0x%x> %@ Exited", (int)ovum, ovum.dataObject);
    
    view.layer.borderColor = [UIColor clearColor].CGColor;
    view.layer.borderWidth = 0.0;

}

-(void) ovumDropped:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
//    NSLog(@"Ovum<0x%x> %@ Dropped", (int)ovum, ovum.dataObject);
    
    view.layer.borderColor = [UIColor clearColor].CGColor;
    view.layer.borderWidth = 0.0;
    
    UILabel *label = (UILabel*) [ovum.dragView viewWithTag:kLabelTag];
    [label removeFromSuperview];
    
    
     if ([ovum.dataObject isKindOfClass:[RingsCell class]] && [view isKindOfClass:[UICollectionView class]] )
    {

        //moved a doll item into the bag
//        RingsCell *itemView = ovum.dataObject;
        preventDuplicateDrop = NO;
    }
    
    else if ([ovum.dataObject isKindOfClass:[InventoryBagCell class]] && [view isKindOfClass:[InventoryDoll class]])
    {
        //dropped a bag item onto the doll
        InventoryBagCell* cell = ovum.dataObject;
        [[[GameDataManager sharedInstance] partyInventory] removeObject:cell.item];
        preventDuplicateDrop = NO;
        
    }else if ([ovum.dataObject isKindOfClass:[ItemImageView class]] && [view isKindOfClass:[UICollectionView class]] )
    {
        //moved a doll item into the bag
        ItemImageView *itemView = ovum.dataObject;
        itemView.image = nil;
        itemView.alpha = 1.0;
        preventDuplicateDrop = NO;
    }else
    {
        preventDuplicateDrop = YES;
        [ovum.dragView removeFromSuperview];
        
    }
}


-(void) handleDropAnimationForOvum:(OBOvum*)ovum withDragView:(UIView*)dragView dragDropManager:(OBDragDropManager*)dragDropManager
{
    if(preventDuplicateDrop)
    { //very rapid tapping on the item in inventory
        return;
    }

    
    if ([ovum.dataObject isKindOfClass:[InventoryBagCell class]] )
    {
        //dropped a bag item onto the doll
        DLog(@"Dropped bag item");
        
        InventoryBagCell* cell = ovum.dataObject;
       
        // Set the initial position of the view to match that of the drag view
        CGRect dragViewFrameInTargetWindow = [ovum.dragView.window convertRect:dragView.frame toWindow:self.inventoryBagCollectionView.window];
        dragViewFrameInTargetWindow = [self.inventoryBagCollectionView convertRect:dragViewFrameInTargetWindow fromView:self.inventoryBagCollectionView.window];
        //        dragView.frame = dragViewFrameInTargetWindow;
        
        CGRect viewFrame = [ovum.dragView.window convertRect:cell.frame fromView:cell.superview];
        Item* oldItem = [self.selectedCharacter addRemove:cell.item add:YES];
        if(oldItem!=nil)
        {
            //add the old item in front, so it is easier to find
            [[[GameDataManager sharedInstance] partyInventory] insertObject:oldItem atIndex:0];
        }
        [self updateDollWithItem:cell.item];
        [self.inventoryBagCollectionView reloadData];
        [self refreshSelectedCharacterStats];
        

        
        void (^animation)() = ^{
            dragView.frame = viewFrame;

            [dragView removeFromSuperview];
        };
        
        [dragDropManager animateOvumDrop:ovum withAnimation:animation completion:nil];
        
    }else if ([ovum.dataObject isKindOfClass:[ItemImageView class]] || [ovum.dataObject isKindOfClass:[RingsCell class]])
    {
        //unequipped the doll item
        ItemImageView *itemView = ovum.dataObject;
        
        // Set the initial position of the view to match that of the drag view
        CGRect dragViewFrameInTargetWindow = [ovum.dragView.window convertRect:dragView.frame toWindow:self.inventoryBagCollectionView.window];
        dragViewFrameInTargetWindow = [self.inventoryBagCollectionView convertRect:dragViewFrameInTargetWindow fromView:self.inventoryBagCollectionView.window];
        //        dragView.frame = dragViewFrameInTargetWindow;
        
        CGRect viewFrame = [ovum.dragView.window convertRect:itemView.frame fromView:itemView.superview];
        
        void (^animation)() = ^{
            dragView.frame = viewFrame;
            
#warning update inventory bag here
            
            [[[GameDataManager sharedInstance] partyInventory] insertObject:itemView.item atIndex:0];
            [self.selectedCharacter addRemove:itemView.item add:NO];
            
            [self.inventoryBagCollectionView reloadData];
            [self refreshSelectedCharacterStats];
            itemView.item = nil;
            [dragView removeFromSuperview];
            //            [self layoutScrollView:leftView withContents:leftViewContents];
            //            [self layoutScrollView:rightView withContents:rightViewContents];
        };
        
        
        [dragDropManager animateOvumDrop:ovum withAnimation:animation completion:nil];
    }

}


//-(IBAction) showMoreItems:(id)sender
//{
//    if (additionalSourcesViewController == nil)
//    {
//        additionalSourcesViewController = [[AdditionalSourcesViewController alloc] initWithNibName:nil bundle:nil];
//    }
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        additionalSourcesViewController.contentSizeForViewInPopover = CGSizeMake(320, 480);
//        sourcesPopoverController = [[UIPopoverController alloc] initWithContentViewController:additionalSourcesViewController];
//        sourcesPopoverController.delegate = self;
//        [sourcesPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//        sourcesPopoverController.passthroughViews = nil;
//    }
//    else {
//        // iPhone case
//        if (additionalSourcesViewController.view.superview != self.view)
//        {
//            additionalSourcesViewController.view.alpha = 0.0;
//            additionalSourcesViewController.view.frame = self.view.bounds;
//            [self.view addSubview:additionalSourcesViewController.view];
//        }
//        
//        [UIView animateWithDuration:0.2 animations:^{
//            additionalSourcesViewController.view.alpha = 1.0;
//        }];
//    }
//}


//- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
//{
//    if (popoverController == sourcesPopoverController)
//    {
//        sourcesPopoverController = nil;
//    }
//}

#pragma mark -
#pragma mark GESTURE recognizers

-(void)handleTapActionWithItem:(Item*)item
{
    if(item!=nil)
    {
        self.selectedItem = item;
    }
}

-(void)didTapOnShield:(UIGestureRecognizer*)gestureRecognizer
{
    DLog(@"didTapOnShield");
    
    [self handleTapActionWithItem:self.selectedCharacter.shieldSlot];
}

-(void)didTapOnAmulet:(UIGestureRecognizer*)gestureRecognizer
{
    DLog(@"didTapOnAmulet");
    [self handleTapActionWithItem:self.selectedCharacter.amuletSlot];

    
}

-(void)didTapOnHelmet:(UIGestureRecognizer*)gestureRecognizer
{
    DLog(@"didTapOnHelmet");
    [self handleTapActionWithItem:self.selectedCharacter.headSlot];

}

-(void)didTapOnBoots:(UIGestureRecognizer*)gestureRecognizer
{
    DLog(@"didTapOnBoots");
    [self handleTapActionWithItem:self.selectedCharacter.bootsSlot];
  
}
-(void)didTapOnCloak:(UIGestureRecognizer*)gestureRecognizer
{
    DLog(@"didTapOnCloak");
    [self handleTapActionWithItem:self.selectedCharacter.cloakSlot];
 
}


-(void)didTapOnWeapon:(UIGestureRecognizer*)gestureRecognizer
{
    DLog(@"didTapOnWeapon");
    [self handleTapActionWithItem:self.selectedCharacter.weaponSlot];
}

-(void)didTapOnSecondaryWeapon:(UIGestureRecognizer*)gestureRecognizer
{
//    DLog(@"didTapOnSecondaryWeapon");
    
    if(self.selectedCharacter.secondaryWeapon)
    {
        if(self.selectedCharacter.acted)
        {
            //if has acted - cannot swap weapons
            iToast* toast =[iToast makeText:@"Cannot swap - already acted!"];
            [toast setPostion:CGPointMake(3*124, 160)];
            [toast setGravity:iToastGravityNatural];
            [toast setDuration:1600];
            [toast show];

        }else
        {
            iToast* toast =[iToast makeText:@"Weapons swapped"];
            [toast setPostion:CGPointMake(3*124, 160)];
            [toast setGravity:iToastGravityNatural];
            [toast setDuration:1000];
            [toast show];
            [self.selectedCharacter swapWeapons];
            [self updateDollWithItem:self.selectedCharacter.weaponSlot];
        }

    }
    [self handleTapActionWithItem:self.selectedCharacter.secondaryWeapon];
}


-(void)didTapOnArmor:(UIGestureRecognizer*)gestureRecognizer
{
    DLog(@"didTapOnArmor");
    [self handleTapActionWithItem:self.selectedCharacter.bodySlot];
}

-(void)setupGestureRecognizers
{
    
    //set up DROP ZONES for drag and drop
    self.inventoryBagCollectionView.dropZoneHandler = self;
    self.inventoryDoll.dropZoneHandler = self;
    
    
    OBDragDropManager *dragDropManager = [OBDragDropManager sharedManager];

    //weapons
    [self.weapon addGestureRecognizer:[dragDropManager createDragDropGestureRecognizerWithClass:[UIPanGestureRecognizer class] source:self]];
    [self.secondaryWeapon addGestureRecognizer:[dragDropManager createDragDropGestureRecognizerWithClass:[UIPanGestureRecognizer class] source:self]];
    
    //armor
    [self.armor addGestureRecognizer:[dragDropManager createDragDropGestureRecognizerWithClass:[UIPanGestureRecognizer class] source:self]];
    [self.boots addGestureRecognizer:[dragDropManager createDragDropGestureRecognizerWithClass:[UIPanGestureRecognizer class] source:self]];
    [self.cloak addGestureRecognizer:[dragDropManager createDragDropGestureRecognizerWithClass:[UIPanGestureRecognizer class] source:self]];
//    [self.amulet addGestureRecognizer:[dragDropManager createDragDropGestureRecognizerWithClass:[UIPanGestureRecognizer class] source:self]];
    [self.shieldImageView addGestureRecognizer:[dragDropManager createDragDropGestureRecognizerWithClass:[UIPanGestureRecognizer class] source:self]];
    
    [self.helmet addGestureRecognizer:[dragDropManager createDragDropGestureRecognizerWithClass:[UIPanGestureRecognizer class] source:self]];
    
    
    //Tap to interact with inventory doll
    
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnWeapon:)];
    [self.weapon addGestureRecognizer:recognizer];
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnSecondaryWeapon:)];
    [self.secondaryWeapon addGestureRecognizer:recognizer];
    
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnArmor:)];
    [self.armor addGestureRecognizer:recognizer];
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnCloak:)];
    [self.cloak addGestureRecognizer:recognizer];
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnBoots:)];
    [self.boots addGestureRecognizer:recognizer];
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnHelmet:)];
    [self.helmet addGestureRecognizer:recognizer];
    
//    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnAmulet:)];
//    [self.amulet addGestureRecognizer:recognizer];
//    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnShield:)];
    [self.shieldImageView addGestureRecognizer:recognizer];
    

}

#pragma mark -
#pragma mark SELECTION

enum Potions
{
    kPotionHealing,
    kPotionStamina,
    kPotionPoisonCure,
    kRagePotion,
    kPotionPower,
    kPotionResurrection
};

-(int)healthPotionValue
{
    int value = fmax( 20,self.selectedCharacter.hp*0.25);
    if(value > 20)
    {
        value = value - (value%5)+5;
    }
    return value;
}

-(int)staminaPotionValue
{
    int value = fmax(15,self.selectedCharacter.sp*0.25);
    if(value > 15)
    {
        value = value - (value%5)+5;
    }
    return value;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([collectionView isEqual:self.inventoryBagCollectionView] )
    {
        
        //update item details with info about selected item
        self.selectedItem = self.inventoryBag[indexPath.row];
   
        //reload item related collection views

        
    }else if([collectionView isEqual:self.ringsCollectionView])
    {
        if(ringsArray.count>0)
        {
            self.selectedItem = ringsArray[indexPath.row];


        }
        //update item details with info about selected item

        
    }else if ([collectionView isEqual:self.potionsCollectionView])
    {
        

            if([[GameDataManager sharedInstance] currentEnergyCount] < 100)
            {
                
                
            }

        NSString* suffix = @"This will require 100 energy.";
        NSString* message  = @"";
        NSString* title = @"Drink Potion?";
        NSString* yea = @"YEA";
        NSString* nay = @"NAY";
        
        switch (indexPath.row) {
            case kPotionHealing:
                
                if(self.selectedCharacter.isDead)
                {
                    pendingPotionAction = kPotionResurrection;
                    message  = [NSString stringWithFormat:@"Should party pour RESURRECTION POTION into %@'s mouth, instantly bringing %@ back to life with half health?\n This will require 500 energy.",self.selectedCharacter.name,self.selectedCharacter.name];

                }else
                {
                    pendingPotionAction = kPotionHealing;
                    message  = [NSString stringWithFormat:@"Should %@ drink POTION OF HEALTH and instantly recover %i health points?\n%@",self.selectedCharacter.name,[self healthPotionValue],suffix];

                }
                break;
                
            case kPotionStamina:
                pendingPotionAction = kPotionStamina;
                
                message  = [NSString stringWithFormat:@"Should %@ drink POTION OF STAMINA and instantly recover %i stamina points?\n%@",self.selectedCharacter.name,[self staminaPotionValue],suffix];
                break;
                
            case kPotionPoisonCure:
                pendingPotionAction = kPotionPoisonCure;
                message  = [NSString stringWithFormat:@"Should %@ drink POTION OF CURE POISON and completely cure all poisons?\n%@",self.selectedCharacter.name,suffix];
                break;
                
            case kRagePotion:
            {
                pendingPotionAction = kRagePotion;
                message  = [NSString stringWithFormat:@"Should %@ eat RAGE MUSHROOM and get +5 to attack/counter for 10 turns?(Does not stack)\n%@",self.selectedCharacter.name,suffix];
                break;
            }
            case kPotionPower:
            {
                pendingPotionAction = kPotionPower;
                message  = [NSString stringWithFormat:@"Should %@ drink POTION OF MAGIC POWER and completely cure all poisons?(Does not stack)\n%@",self.selectedCharacter.name,suffix];
               
                break;
            }
            default:
                break;
        }
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:nay otherButtonTitles:yea, nil];
        
        [alertView show];
    }
    
    
}



- (IBAction)resurrectAction:(id)sender {
    self.selectedCharacter.isDead = NO;
    self.selectedCharacter.currentHP = self.selectedCharacter.hp/2.0;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.firstOtherButtonIndex)
    {
        [self drinkPotion];
    }else
    {
        pendingPotionAction = -1;
    }
}
-(void)drinkPotion
{
    

    
    switch (pendingPotionAction) {
        case kPotionHealing:
             [self standardPotionPrice];
            self.selectedCharacter.currentHP = fmin(self.selectedCharacter.hp, self.selectedCharacter.currentHP + [self healthPotionValue]);
            break;
            
        case kPotionStamina:
             [self standardPotionPrice];
             self.selectedCharacter.currentSP = fmin(self.selectedCharacter.sp, self.selectedCharacter.currentSP + [self staminaPotionValue]);
            break;
            
        case kPotionPoisonCure:
             [self standardPotionPrice];
            [self.selectedCharacter addRemove:[BuffEffect buffWithEffectType:kEffectPoisonReduction intensity:99] add:YES];
            
            break;
            
        case kRagePotion:
        {
             [self standardPotionPrice];
            BuffCollection* buffCollection = [[BuffCollection alloc] initWithCaster:self.selectedCharacter];
            
            BuffEffect* buffBase = [BuffEffect buffWithType:kBuffAlwaysOn
                                                 effectType:kEffectMeleeBonus
                                                  intensity:5
                                             buffCollection:buffCollection target:self.selectedCharacter];
            
            buffBase.buffAction = [[BuffAction alloc] initWithType:kActionTypeExpire value:10];
            
            [self.selectedCharacter addRemove:buffBase add:YES];
        
            break;
        }
        case kPotionPower:
        {
            [self standardPotionPrice];
            BuffCollection* buffCollection = [[BuffCollection alloc] initWithCaster:self.selectedCharacter];
            
            BuffEffect* buffBase = [BuffEffect buffWithType:kBuffAlwaysOn
                                                 effectType:kEffectMagicBonus
                                                  intensity:4
                                             buffCollection:buffCollection target:self.selectedCharacter];
            buffBase.buffAction = [[BuffAction alloc] initWithType:kActionTypeExpire value:10];
            
            [self.selectedCharacter addRemove:buffBase add:YES];
            
        break;
        }
        case kPotionResurrection:
        {
            
            if([[GameDataManager sharedInstance] currentEnergyCount]>=500)
            {
                [[GameDataManager sharedInstance] increaseEnergyCountBy:-500];
                [self resurrectAction:nil];
                
            }
            
            break;
        }
        default:
            break;
    }
    
    
   
}
-(void)standardPotionPrice
{
    if([[GameDataManager sharedInstance] currentEnergyCount]>=100)
    {
        [[GameDataManager sharedInstance] increaseEnergyCountBy:-100];
      
        
    }
}

//
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    
//    if([collectionView isEqual:self.potionsCollectionView])
//    {
//    CGFloat rightEdge = 0;
//    CGFloat interItemSpacing = [(UICollectionViewFlowLayout*)collectionViewLayout minimumInteritemSpacing];
//    
//    for(NSString * tag in _tags)
//        rightEdge += [tag sizeWithFont:[UIFont systemFontOfSize:14]].width+interItemSpacing;
//    
//    // To center the inter spacing too
//    rightEdge -= interSpacing/2;
//    
//    // Calculate the inset
//    CGFloat inset = collectionView.frame.size.width-rightEdge;
//    
//    // Only center align if the inset is greater than 0
//    // That means that the total width of the cells is less than the width of the collection view and need to be aligned to the center.
//    // Otherwise let them align left with no indent.
//    
//    if(inset > 0)
//        return UIEdgeInsetsMake(0, inset/2, 0, 0);
//    else
//        return UIEdgeInsetsMake(0, 0, 0, 0);
//        
//    }else
//    {
//        return collectionView
//    }
//}

-(void)topLevelSetup
{
#warning  a dirty workaround for parent class load controller infinite recursion
}


#pragma mark -
#pragma mark UIViewController Container Methods
- (BOOL)shouldAutomaticallyForwardRotationMethods{
    return YES;
}

-(void)swapViewControllers{

    [item3.view layoutIfNeeded];
    

        item3.view.frame=self.item1Container.bounds;

    
    [item1 willMoveToParentViewController:nil];
    
//    item3.titleLabel.text = @"Item3";
    
    __weak __block InventoryViewController *weakSelf=self;
    [self transitionFromViewController:item1
                      toViewController:item3
                              duration:0.1
                               options:UIViewAnimationOptionTransitionFlipFromBottom
                            animations:nil
                            completion:^(BOOL finished) {
                                
                                [item1 removeFromParentViewController];
                                [item3 didMoveToParentViewController:weakSelf];
                                
                                [item1.view layoutIfNeeded];
                                
                                
                                item1.view.frame=self.item2Container.bounds;
                                    
                                
                                
                                [item2 willMoveToParentViewController:nil];
                                [self addChildViewController:item1];
                                
                                [self transitionFromViewController:item2
                                                  toViewController:item1
                                                          duration:0.1
                                                           options:UIViewAnimationOptionTransitionFlipFromBottom
                                                        animations:nil
                                                        completion:^(BOOL f) {
                                                            
                                                            [item2 removeFromParentViewController];
                                                            [item1 didMoveToParentViewController:weakSelf];
                                                            

                                                            
                                                            ItemStatsViewController* temp = item2;
                                                            item2 = item3;
                                                            item3 = item1;
                                                            item1 = temp;
                                                            
                                                            item1.titleLabel.text = @"Item 1";
                                                            item2.titleLabel.text = @"Item 2";
                                                            item3.titleLabel.text = @"Item 3";
                                                            
                                                            [self addChildViewController:item1];
                                                            [self addChildViewController:item2];
                                                            [self addChildViewController:item3];
                                                            
                                                            
                                                        }];

                                
                            }];
}

-(void)characterUpdated
{
    [self.potionsCollectionView reloadData];
}

-(void)prepareForDeletion
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
