
#import "NNSegmentedControl.h"

@interface NNSegmentedControl(){
    NSMutableArray *_buttonArray;
    UIImageView *_pointerView;
}
- (void)setButtonBackgroundImage:(UIButton *)button buttonIndex:(NSInteger)buttonIndex selected:(BOOL)selected;

@end

@implementation NNSegmentedControl

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
//    _pointerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"seg_control_pointer.png"]];
}

- (void)layoutSubviews {
    float segmentWidth = self.frame.size.width / [_buttonArray count];
    float segmentStartX = 0;
    for (int i = 0; i < [_buttonArray count]; i++) {
        UIButton *button = [_buttonArray objectAtIndex:i];
        button.frame = CGRectMake(segmentStartX, 0, segmentWidth, self.frame.size.height);
        
//        if (selectedSegmentIndex == i) {
//            _pointerView.frame = CGRectMake(segmentStartX + (segmentWidth - 28) / 2, self.frame.size.height - 1, 28, 7);
//        }
        segmentStartX += segmentWidth;
    }
//    [_pointerView removeFromSuperview];
//    [self addSubview:_pointerView];
}

- (void)setEnabled:(BOOL)aEnabled {
    for (int i = 0; i < [_buttonArray count]; i++) {
        UIButton *button = [_buttonArray objectAtIndex:i];
        [button setEnabled:aEnabled];
    }
}

- (void)setNumberOfSegments:(NSUInteger)aNumberOfSegments {
    _buttonArray=nil;
    _numberOfSegments = aNumberOfSegments;
    _buttonArray = [NSMutableArray arrayWithCapacity:_numberOfSegments];
    for (int i=0; i <_numberOfSegments; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            [self setButtonBackgroundImage:button buttonIndex:i selected:YES];
        } else {
            [self setButtonBackgroundImage:button buttonIndex:i selected:NO];
        }
        //778bad
        [button titleLabel].font = [UIFont boldSystemFontOfSize:16];
//        [button setTitleColor:[UIColor colorWithRed:0x77/255.f green:0x8b/255.f blue:0xad/255.f alpha:1] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

        [button setTag:i];
        [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonArray addObject:button];
        [self addSubview:button];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)aSelectedSegmentIndex {
    UIButton *preButton = [_buttonArray objectAtIndex:_selectedSegmentIndex];
    [self setButtonBackgroundImage:preButton buttonIndex:_selectedSegmentIndex selected:NO];
    
    _selectedSegmentIndex = aSelectedSegmentIndex;
    UIButton *button = [_buttonArray objectAtIndex:_selectedSegmentIndex];
    [self setButtonBackgroundImage:button buttonIndex:_selectedSegmentIndex selected:YES];
    
    [_delegate valueChanged:self selectedSegmentIndex:_selectedSegmentIndex];
}

- (void)setButtonBackgroundImage:(UIButton *)button buttonIndex:(NSInteger)buttonIndex selected:(BOOL)selected {
    if (selected) {
       [button setBackgroundImage:[UIImage imageNamed:@"seg_control_on_tex.png"] forState:UIControlStateNormal]; 
        [button setBackgroundImage:[UIImage imageNamed:@"seg_control_on_tex.png"] forState:UIControlStateHighlighted]; 
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"seg_control_off_tex.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"seg_control_on_tex_pressed.png"] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }    
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment {
    UIButton *button = [_buttonArray objectAtIndex:segment];
    [button setTitle:title forState:UIControlStateNormal];
}

- (void)action:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == _selectedSegmentIndex) {
        return;
    }
    [self setSelectedSegmentIndex:button.tag];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//    [UIView setAnimationDuration:0.3];
//    _pointerView.frame = CGRectMake(button.frame.size.width * selectedSegmentIndex + (button.frame.size.width - 28) / 2, self.frame.size.height - 1, 28, 7);
//    [UIView commitAnimations];
}

@end
