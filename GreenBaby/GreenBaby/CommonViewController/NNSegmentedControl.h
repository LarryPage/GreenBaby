

#import <UIKit/UIKit.h>

@class NNSegmentedControl;
@protocol NNSegmentedControlDelegate <NSObject>

- (void)valueChanged:(NNSegmentedControl *)segmentedControl selectedSegmentIndex:(NSInteger)index;

@end

@interface NNSegmentedControl : UIView
@property (nonatomic, weak) id<NNSegmentedControlDelegate> delegate;
@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic) NSUInteger numberOfSegments;
@property (nonatomic) BOOL enabled;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;

@end
