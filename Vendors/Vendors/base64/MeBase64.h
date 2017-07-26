//为了不和ShareSDK中微博接口中的base64接口冲突，现每个方法加上Me
extern size_t MeEstimateBas64EncodedDataSize(size_t inDataSize);
extern size_t MeEstimateBas64DecodedDataSize(size_t inDataSize);

extern bool MeBase64EncodeData(const void *inInputData, size_t inInputDataSize, char *outOutputData, size_t *ioOutputDataSize, BOOL wrapped);
extern bool MeBase64DecodeData(const void *inInputData, size_t inInputDataSize, void *ioOutputData, size_t *ioOutputDataSize);