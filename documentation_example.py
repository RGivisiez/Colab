def guess_thresholds(data, bins=16000, win_length=200,
                     maxima_threshold=0, only_histogram=False):
    """
    Give a first guess for photon number thresholds by creating a
    smoothed histogram using Hann windows.

    Can also be used to only calculate the histogram, if
    only_histogram = True.

    To plot the results obtained in this function you can use
    plot_guess (in module tes_plotting.py).

    Parameters:
    -----------

    data : ndarray
        The measurement data.

    bins : int
        Number of the histogram bins.

    win_length : int
        Hanning window length used for smoothing.

    maxima_threshold : int
        passed to maxima function

    only_histogram : bool
        When true, only calculates the histogram.

    Returns:
    --------
    Guess(hist, smooth_hist, bin_c, max_i, thresholds) : named tuple
        hist : list
            Histogram to be plotted.

        smooth_hist : list
            Smoothed histogram. Returns empty list if
            only_histogram = True.

        bin_c : ndarray
            Positions of histogram bin centers.

        max_i : list
            List with indices of maxima in the smoothed histogram.
            Returns empty list if only_histogram = True.

        thresholds : list
            List with first threshold guesses. Returns empty list if
            only_histogram = True.

    Requires:
    ---------
        maxima : function
            function to find the maxima points of a function, defined
            in tes_calibration.py module.

    Notes:
    ------
        The smoothing is achieved by convolving the Hanning window with
        a histogram generated using numpy.histogram. The guess still
        needs some human sanity checks, especially multiple maxima per
        photon peak. Use plot_guess() and adjust window and
        maxima_threshold to remove them.

    """
    hist, edges = np.histogram(data, bins=bins)
    bin_w = edges[1] - edges[0]
    bin_c = edges[:-1] + bin_w / 2

    if only_histogram == True:
        return Guess(hist, [], bin_c, [], [], only_histogram)

    else:

        # smooth the histogram

        win = signal.hann(win_length)
        smooth_hist = signal.convolve(hist, win, mode='same')/sum(win)

        max_i = maxima(smooth_hist, thresh=maxima_threshold)
        max_list = [0.0] + list(bin_c[max_i])
        thresh = [max_list[i - 1] + (max_list[i] - max_list[i - 1])/2
                  for i in range(2, len(max_list))]
        # adding the first threshold ([0.0]) and the last to the threshold
        # list
        thresholds = np.array([0.0] + thresh + [max_list[-1] + (max_list[-1]
                                                                - thresh[-1])*1.10])

        return Guess(hist, smooth_hist, bin_c, max_i, thresholds, only_histogram)

def maxima(function, thresh=10):
    """
    Find local maxima of a function using rising zero crossings of the
    gradient of f.

    Parameters:
    -----------

    f : ndarray
        Function f to be analysed.
    thresh : int
        Only return a maxima if f[maxima] > thresh

    Returns:
    --------
        : array
        Array with maxima points of f.
    """
    grad = np.gradient(function)
    pos = grad > 0
    xings = (pos[:-1] & ~pos[1:]).nonzero()[0]
    return xings[np.where(function[xings] > thresh)]