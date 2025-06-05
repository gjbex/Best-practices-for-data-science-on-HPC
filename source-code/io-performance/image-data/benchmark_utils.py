def brightness(img):
    return img.sum()/(img.shape[0]*img.shape[1]*img.shape[2]*255)
